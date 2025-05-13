import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/cloud_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/utils/udp_service.dart';
import 'package:bluetooth_mini/utils/pc_communication_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'dart:async';

class Cloud extends StatefulWidget
{
    const Cloud({Key? key}) : super(key: key);

    @override
    State<Cloud> createState() => _CloudState();
}

class _CloudState extends State<Cloud>
{
    List<CloudModel> employees = <CloudModel>[];
    List<RepoModel> _repoModels = [];
    final UdpService _udpService = UdpService();
    final PcCommunicationService _pcService = PcCommunicationService();
    StreamSubscription? _deviceSubscription;
    bool _isDiscovering = false;
    bool _pcConnected = false;
    Set<int> _selectedItems = {};
    bool _selectAll = false;
    Timer? _discoveryTimeoutTimer;

    late EmployeeDataSource employeeDataSource =
        EmployeeDataSource(employeeData: employees);

    @override
    void initState()
    {
        super.initState();
        _initUdpService();
        getList();
    }

    Future<void> _initUdpService() async
    {
        // 取消之前的订阅
        if (_deviceSubscription != null) {
            await _deviceSubscription!.cancel();
            _deviceSubscription = null;
        }
        
        await _udpService.init();
        // 监听PC设备的发现
        _deviceSubscription = _udpService.deviceStream.listen((data)
            {
                if (data['type'] == 'pc_response' || data['type'] == 'server_announce' || data['type'] == 'server_response')
                {
                    _onPcDeviceFound(data);
                }
            }
        );
    }

    void _onPcDeviceFound(Map<String, dynamic> data)
    {
        _discoveryTimeoutTimer?.cancel();
        _discoveryTimeoutTimer = null;

        debugPrint('发现钻孔轨迹仪数据处理系统服务器: ${data.toString()}');
        SmartDialog.showToast('发现服务器: ${data['name'] ?? "钻孔轨迹仪数据处理系统 Server"}');

        // 停止继续发现UDP服务，但不关闭 StreamController
        _udpService.stopDiscoveryAll();

        setState(()
            {
                _isDiscovering = false;
            }
        );

        // 设置服务器信息
        _pcService.setServer(data);

        // 测试连接
        SmartDialog.showLoading(msg: '正在连接服务器...');
        _pcService.testConnection().then((connected)
            {
                SmartDialog.dismiss();
                setState(()
                    {
                        _pcConnected = connected;
                    }
                );

                if (connected)
                {
                    final server = _pcService.currentServer!;
                    SmartDialog.showToast('已成功连接到服务器: ${server.name}');
                    // 连接成功后，获取同步状态
                    _updateSyncStatus();
                }
                else
                {
                    SmartDialog.showToast('连接服务器失败，请检查服务器是否正常运行');
                }
            }
        );
    }

    Future<void> getList() async
    {
        List<RepoModel> list = await DatabaseHelper().getRepos();

        setState(()
            {
                _repoModels = list;
                employees = transfromCloud(list);
                employeeDataSource = EmployeeDataSource(
                    employeeData: employees,
                    onSelected: _onItemSelected,
                    isSelected: _isItemSelected,
                    onSync: _syncToPc
                );
            }
        );
    }

    List<CloudModel> transfromCloud(List<RepoModel> repoModels)
    {
        // 将 List<RepoModel> 转换为 List<CloudModel>
        List<CloudModel> cloudModels = repoModels.map((repo)
            {
                return CloudModel(
                    repo.id!,
                    repo.name,
                    repo.mnTime,
                    '未同步' // 初始状态为"未同步"
                );
            }
        ).toList();
        return cloudModels;
    }

    // 更新同步状态
    Future<void> _updateSyncStatus() async
    {
        if (!_pcConnected) return;

        SmartDialog.showLoading(msg: '正在获取同步状态...');
        try
        {
            List<Map<String, dynamic>> statusList = await _pcService.getSyncStatus();

            setState(()
                {
                    for (var status in statusList)
                    {
                        int id = status['id'];
                        bool synced = status['synced'] ?? false;

                        for (int i = 0; i < employees.length; i++)
                        {
                            if (employees[i].id == id)
                            {
                                employees[i] = CloudModel(
                                    employees[i].id,
                                    employees[i].name,
                                    employees[i].mnTime,
                                    synced ? '已同步' : '未同步'
                                );
                                break;
                            }
                        }
                    }

                    employeeDataSource = EmployeeDataSource(
                        employeeData: employees,
                        onSelected: _onItemSelected,
                        isSelected: _isItemSelected,
                        onSync: _syncToPc
                    );
                }
            );
        }
        catch (e)
        {
            debugPrint('获取同步状态失败: $e');
        }
        finally
        {
            SmartDialog.dismiss();
        }
    }

    // 开始发现服务器
    void _discoverPcDevices()
    {
        if (_isDiscovering) {
            return;
        }

        _discoveryTimeoutTimer?.cancel();

        // 先初始化UDP服务
        _initUdpService().then((_)
            {
                setState(()
                    {
                        _isDiscovering = true;
                        _pcConnected = false;
                    }
                );

                SmartDialog.showToast('正在搜索钻孔轨迹仪数据处理系统服务器...');
                debugPrint('开始搜索钻孔轨迹仪数据处理系统服务器');
                _udpService.discoverPcDevices();

                // 设置超时，如果15秒内未发现服务器，则停止搜索
                _discoveryTimeoutTimer = Timer(const Duration(seconds: 15), ()
                    {
                        if (mounted && _isDiscovering && !_pcConnected)
                        {
                            setState(()
                                {
                                    _isDiscovering = false;
                                }
                            );
                            _udpService.stopDiscoveryAll();
                            SmartDialog.showToast('未发现钻孔轨迹仪数据处理系统服务器，请确认服务器是否运行，并检查网络连接');
                            debugPrint('搜索超时，未发现服务器');
                        }
                    }
                );
            }
        );
    }

    // 同步单个项目到服务器
    Future<void> _syncToPc(int id) async
    {
        if (!_pcConnected)
        {
            SmartDialog.showToast('未连接到服务器，请先搜索服务器');
            return;
        }

        RepoModel? repo;
        for (var r in _repoModels)
        {
            if (r.id == id)
            {
                repo = r;
                break;
            }
        }

        if (repo == null)
        {
            SmartDialog.showToast('未找到相关数据');
            return;
        }

        SmartDialog.showLoading(msg: '正在同步数据...');
        try
        {
            bool success = await _pcService.syncDataToPC(repo);

            if (success)
            {
                SmartDialog.showToast('同步成功');
                // 更新同步状态
                _updateSyncStatus();
            }
            else
            {
                SmartDialog.showToast('同步失败');
            }
        }
        catch (e)
        {
            SmartDialog.showToast('同步错误: ${e.toString()}');
        }
        finally
        {
            SmartDialog.dismiss();
        }
    }

    // 同步所有项目
    Future<void> _syncAllToPc() async
    {
        if (!_pcConnected)
        {
            SmartDialog.showToast('未连接到服务器，请先搜索服务器');
            return;
        }

        if (_repoModels.isEmpty)
        {
            SmartDialog.showToast('没有可同步的项目');
            return;
        }

        SmartDialog.showLoading(msg: '正在同步所有数据...');
        try
        {
            Map<int, bool> results = await _pcService.batchSyncData(_repoModels);

            int successCount = results.values.where((success) => success).length;
            SmartDialog.showToast('同步完成: $successCount/${results.length} 个项目成功');

            // 更新同步状态
            _updateSyncStatus();
        }
        catch (e)
        {
            SmartDialog.showToast('同步错误: ${e.toString()}');
        }
        finally
        {
            SmartDialog.dismiss();
        }
    }

    // 选择/取消选择单个项目
    void _onItemSelected(int id, bool selected)
    {
        setState(()
            {
                if (selected)
                {
                    _selectedItems.add(id);
                }
                else
                {
                    _selectedItems.remove(id);
                    _selectAll = false;
                }
            }
        );
    }

    // 判断项目是否被选中
    bool _isItemSelected(int id)
    {
        return _selectedItems.contains(id);
    }

    @override
    void dispose()
    {
        _discoveryTimeoutTimer?.cancel();
        
        // 取消订阅
        if (_deviceSubscription != null)
        {
            _deviceSubscription!.cancel();
            _deviceSubscription = null;
        }

        // 销毁 UDP 服务
        _udpService.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: const CustomAppBar('同步云端'),
            body: Container(
                color: const Color.fromRGBO(238, 239, 241, 0.8),
                child: Container(
                    margin: const EdgeInsets.only(
                        left: 10,
                        bottom: 10,
                        right: 10,
                        top: 10
                    ),
                    color: Colors.white,
                    padding: const EdgeInsets.all(5),
                    child: Column(
                        children: [
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                    children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                if (_pcConnected && _pcService.currentServer != null) ...[
                                                    const SizedBox(height: 10),
                                                    Column(
                                                        children: [
                                                            Text(
                                                                '服务器: ${_pcService.currentServer!.name}',
                                                                style: const TextStyle(fontSize: 14, color: Colors.green)
                                                            ),
                                                            Text(
                                                                '地址: ${_pcService.currentServer!.ipAddress}:${_pcService.currentServer!.httpPort}',
                                                                style: const TextStyle(fontSize: 14, color: Colors.green)
                                                            )
                                                        ]
                                                    ),
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.blue,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            )
                                                        ),
                                                        onPressed: _updateSyncStatus,
                                                        child: const Text('刷新状态',
                                                            style: TextStyle(fontSize: 14, color: Colors.white))
                                                    )
                                                ],
                                                Row(
                                                    children: [
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: _pcConnected ? Colors.green : Colors.orange,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                )
                                                            ),
                                                            onPressed: _isDiscovering ? null : _discoverPcDevices,
                                                            child: Text(
                                                                _pcConnected
                                                                    ? '已连接服务器'
                                                                    : (_isDiscovering ? '搜索中...' : '搜索服务器'),
                                                                style: const TextStyle(fontSize: 16, color: Colors.white)
                                                            )
                                                        ),
                                                        const SizedBox(width: 10),
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.blue,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                )
                                                            ),
                                                            child: const Text('一键同步', 
                                                                style: TextStyle(fontSize: 16, color: Colors.white)),
                                                            onPressed: _syncAllToPc
                                                        )
                                                    ]
                                                )
                                            ]
                                        )
                                    ]
                                )
                            ),
                            const SizedBox(
                                height: 10
                            ),
                            Expanded(
                                flex: 1,
                                child: SfDataGrid(
                                    source: employeeDataSource,
                                    columnWidthMode: ColumnWidthMode.fill,
                                    columns: <GridColumn>[
                                        GridColumn(
                                            columnName: 'id',
                                            label: Container(
                                                padding: const EdgeInsets.all(16.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                    '序号'
                                                ))),
                                        GridColumn(
                                            columnName: 'name',
                                            label: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                alignment: Alignment.center,
                                                child: const Text('名称'))),
                                        GridColumn(
                                            columnName: 'mnTime',
                                            label: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                    '时间',
                                                    overflow: TextOverflow.ellipsis
                                                ))),
                                        GridColumn(
                                            columnName: 'state',
                                            label: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                    '状态',
                                                    overflow: TextOverflow.ellipsis
                                                ))),
                                        GridColumn(
                                            columnName: 'actions',
                                            label: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                    '操作',
                                                    overflow: TextOverflow.ellipsis
                                                )))
                                    ]
                                )
                            )
                        ]
                    )
                )
            )
        );
    }
}

/// 修改 EmployeeDataSource 类以支持选择功能
class EmployeeDataSource extends DataGridSource
{
    final Function(int, bool)? onSelected;
    final bool Function(int)? isSelected;
    final Function(int)? onSync;

    /// Creates the employee data source class with required details.
    EmployeeDataSource({
        required List<CloudModel> employeeData, 
        this.onSelected,
        this.isSelected,
        this.onSync
    })
    {
        _employeeData = employeeData
            .map<DataGridRow>((e) => DataGridRow(cells: [
                        DataGridCell<int>(columnName: 'id', value: e.id),
                        DataGridCell<String>(columnName: 'name', value: e.name),
                        DataGridCell<String>(columnName: 'mnTime', value: e.mnTime),
                        DataGridCell<String>(columnName: 'state', value: e.state),
                        DataGridCell<Widget>(
                            columnName: 'actions',
                            value: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    )
                                ),
                                child: const Text('同步', style: TextStyle(color: Colors.white)),
                                onPressed: ()
                                {
                                    if (onSync != null)
                                    {
                                        onSync!(e.id);
                                    }
                                }
                            )
                        )
                    ]))
            .toList();
    }

    List<DataGridRow> _employeeData = [];

    @override
    List<DataGridRow> get rows => _employeeData;

    @override
    DataGridRowAdapter buildRow(DataGridRow row)
    {
        final int id = row.getCells().first.value as int;
        final bool selected = isSelected != null ? isSelected!(id) : false;

        return DataGridRowAdapter(
            color: selected ? Colors.lightBlue.withOpacity(0.2) : null,
            cells: row.getCells().map<Widget>((e)
                {
                    if (e.columnName == 'actions')
                    {
                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: e.value
                        );
                    }
                    if (e.columnName == 'id')
                    {
                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Checkbox(
                                        value: selected,
                                        onChanged: (value)
                                        {
                                            if (onSelected != null && value != null)
                                            {
                                                onSelected!(id, value);
                                            }
                                        }
                                    ),
                                    Text(e.value.toString())
                                ]
                            )
                        );
                    }
                    if (e.columnName == 'state')
                    {
                        Color textColor;
                        switch (e.value)
                        {
                            case '已同步':
                                textColor = Colors.green;
                                break;
                            case '未同步':
                                textColor = Colors.red;
                                break;
                            default:
                            textColor = Colors.black;
                        }

                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                e.value.toString(),
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
                            )
                        );
                    }
                    return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.value.toString())
                    );
                }
            ).toList()
        );
    }
}
