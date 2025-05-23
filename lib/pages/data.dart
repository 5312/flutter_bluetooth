import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/my_time.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'dart:async';
import '../utils/analytical.dart';

class DataTransmission extends StatefulWidget
{
    const DataTransmission({Key? key}) : super(key: key);

    @override
    State<DataTransmission> createState() => _DataTransmissionState();
}

class _DataTransmissionState extends State<DataTransmission>
{
    late BluetoothManager bluetooth;

    late List<DataListModel> employees = <DataListModel>[];
    late EmployeeDataSourceData employeeDataSource =
        EmployeeDataSourceData(dataModels: []);

    // 添加表格控制器
    final DataGridController _dataGridController = DataGridController();

    String _mineString = '';
    String _workString = '';
    String _factoryString = '';
    String _drillingString = '';
    String _name = '';
    int _repoId = 0;
    final List<List<int>> _backList = [];

    // 选中特征码
    BluetoothCharacteristic? targetCharacteristic;

    // 监听订阅
    StreamSubscription<List<int>>? _lastValueSubscription;

    @override
    void initState()
    {
        _mineString = MyTime.getMine() ?? '';
        _workString = MyTime.getWork() ?? '';
        _factoryString = MyTime.getFactory() ?? '';
        _drillingString = MyTime.getDirlling() ?? '';
        _name = MyTime.getMonName() ?? '';
        _repoId = MyTime.getRepoId() ?? 0;

        getDatabaseData();
        // 先弹窗
        bluetooth = Provider.of<BluetoothManager>(context, listen: false);

        WidgetsBinding.instance.addPostFrameCallback((_)
            {
                if (bluetooth.currentDevice == null)
                {
                    Navigator.of(context).pop();
                    SmartDialog.showToast('请连接蓝牙');
                }
            }
        );
        super.initState();
    }

    // foreach 读取特征值
    void readServiceFunction(service)
    {
        // 具名函数的内容
        if (service.uuid.toString() == 'ffe0')
        {
            // Reads all characteristics
            var characteristics = service.characteristics;
            for (BluetoothCharacteristic c in characteristics)
            {
                if (c.uuid.toString() == 'ffe1')
                {
                    // 例如读取特征码的值
                    if (mounted)
                    {
                        setState(()
                            {
                                targetCharacteristic = c;
                                handleSync(c);
                            }
                        );
                    }

                    // readCharacteristicValue();
                    // writeAndListen();
                }
            }
        }
    }

    // 读取指定服务及特征值
    void discoverServices(BluetoothDevice? onConnectdevice) async
    {
        if (onConnectdevice == null)
        {
            SmartDialog.showToast('未连接设备');
            return;
        }
        if (!onConnectdevice.isConnected)
        {
            SmartDialog.showToast('请连接设备后再试！');
            return;
        }
        try
        {
            EasyLoading.show(status: '正在获取设备服务...');
            List<BluetoothService> services = await onConnectdevice.discoverServices()
                .timeout(const Duration(seconds: 5), onTimeout: ()
                    {
                        throw TimeoutException('获取服务超时');
                    }
                );

            await onConnectdevice.requestMtu(512);

            // 检查是否找到了目标服务
            bool foundTargetService = false;
            services.forEach((service)
                {
                    if (service.uuid.toString() == 'ffe0')
                    {
                        foundTargetService = true;
                        readServiceFunction(service);
                    }
                }
            );

            if (!foundTargetService)
            {
                EasyLoading.dismiss();
                SmartDialog.showToast('未找到目标服务，请检查设备');
            }
        }
        catch (e)
        {
            EasyLoading.dismiss();
            SmartDialog.showToast('获取设备服务出错: $e');
        }
    }
    // 发送命令
    Future<void> handleSync1(BluetoothCharacteristic c) async
    {
        // 写入数据到特征码 启动采集
        try
        {
            await c.write([0x68, 0x05, 0x00, 0x71, 0x00, 0x76], withoutResponse: false);

            await c.write([
                    0x68,
                    0x0C,
                    0x00,
                    0x73,
                    0x02,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x81
                ], withoutResponse: false);

            EasyLoading.show(status: '正在等待设备返回...');
            // 创建一个超时标志
            bool hasReceivedData = false;

            // 设置超时处理
            Future.delayed(const Duration(seconds: 10), ()
                {
                    if (!hasReceivedData)
                    {
                        EasyLoading.dismiss();
                        SmartDialog.showToast('设备响应超时，请重试');
                        _lastValueSubscription?.cancel();
                    }
                }
            );
            // 监听特征码的通知
            await c.setNotifyValue(true);
            _lastValueSubscription = c.onValueReceived.listen((value)
                {
                    hasReceivedData = true;
                    _backList.add(value);
                    print('value: $value');
                    // 收到第一条数据时，更新加载提示文字
                    if (_backList.length == 1)
                    {
                        EasyLoading.dismiss();
                        EasyLoading.show(status: '正在接收数据...');
                    }
                    // 每次接收到数据后立即同步
                    getData(_backList);
                }
            );
        }
        catch (e)
        {
            EasyLoading.dismiss();
            SmartDialog.showToast('发送命令失败: $e');
        }
    }
    // 发送命令
    Future<void> handleSync(BluetoothCharacteristic c) async
    {
        if (employees.isEmpty)
        {
            SmartDialog.showToast('表格中没有时间数据，无法获取');
            EasyLoading.dismiss();
            return;
        }

        try
        {
            // 发送停止采集命令
            await c.write([0x68, 0x05, 0x00, 0x71, 0x00, 0x76], withoutResponse: false);

            int currentIndex = 0;

            Future<void> sendNextCommand() async
            {
                if (currentIndex >= employees.length)
                {
                    // 全部完成
                    await _lastValueSubscription?.cancel();
                    _lastValueSubscription = null;
                    EasyLoading.dismiss();
                    SmartDialog.showToast('数据读取完成');
                    return;
                }
                String timeStr = employees[currentIndex].time ?? '00:00:00';
                List<String> parts = timeStr.split(':');
                int seconds = 0;
                if (parts.length == 3)
                {
                    int hour = int.tryParse(parts[0]) ?? 0;
                    int minute = int.tryParse(parts[1]) ?? 0;
                    int second = int.tryParse(parts[2]) ?? 0;
                    seconds = hour * 3600 + minute * 60 + second;
                }
                print('第' + seconds.toString() + '秒');

                int byte1 = 0x00;  // 第1字节固定0
                int byte2 = (seconds >> 8) & 0xFF;  // 取高8位
                int byte3 = seconds & 0xFF;         // 取低8位
                List<int> readCommand = [0x68, 0x0C, 0x00, 0x72, byte1, byte2, byte3];
                int checksum = readCommand.reduce((a, b) => a + b) & 0xFF;
                readCommand.add(checksum);
                // 打印调试（十六进制）
                print(readCommand);
                print('发送命令（十六进制）：' + readCommand.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' '));
                // await c.write(readCommand, withoutResponse: false); 命令失效暂时禁用
                await c.write([
                        0x68,
                        0x0C,
                        0x00,
                        0x73,
                        0x02,
                        0x00,
                        0x00,
                        0x00,
                        0x00,
                        0x00,
                        0x00,
                        0x00,
                        0x81
                    ], withoutResponse: false);
                EasyLoading.show(status: '正在读取第 ${currentIndex + 1}/${employees.length} 条数据...');
            }
            await c.setNotifyValue(true);
            _lastValueSubscription = c.onValueReceived.listen((value) async
                {
                    setTableData(value);
                    currentIndex++;
                    if (currentIndex < employees.length)
                    {
                        // await sendNextCommand();
                    }
                    else
                    {
                        // await _lastValueSubscription?.cancel();
                        _lastValueSubscription = null;
                        EasyLoading.dismiss();
                    }
                }
            );

            // 启动第一次
            await sendNextCommand();
        }
        catch (e)
        {
            EasyLoading.dismiss();
            SmartDialog.showToast('发送命令失败: $e');
        }
    }

    void setTableData(List<int> deviceBack)
    {
        Analytical analytical = Analytical(deviceBack);
        String dataTime = analytical.dataTime();
        String roll = analytical.getRoll();
        String heading = analytical.getHeading();
        String pitch = analytical.getPitch();
        print('解析数据: 时间=$dataTime, roll=$roll, heading=$heading, pitch=$pitch');
        // 更新表格中对应时间的数据
        List<DataListModel> r = employees.map((e)
            {
                if (e.time == dataTime)
                {
                    e.roll = double.parse(roll);
                    e.heading = double.parse(heading);
                    e.pitch = double.parse(pitch);
                    return e;
                }
                return e;
            }
        ).toList();

        setState(()
            {
                employees = r;
                employeeDataSource = EmployeeDataSourceData(dataModels: r);

                // 查找当前更新的数据在列表中的索引
                int updatedRowIndex = -1;
                for (int i = 0; i < employees.length; i++)
                {
                    if (employees[i].time == dataTime)
                    {
                        updatedRowIndex = i;
                        break;
                    }
                }

                // 如果找到了被更新的行，滚动到该行
                if (updatedRowIndex != -1)
                {
                    WidgetsBinding.instance.addPostFrameCallback((_)
                        {
                            _dataGridController.scrollToRow(updatedRowIndex.toDouble(), canAnimate: true);
                        }
                    );
                }
            }
        );
    }
    void getData(List<List<int>> originalArray)
    {
        print('originalArray: $originalArray');
        // 打印每一段
        for (var chunk in originalArray)
        {
            try
            {
                Analytical analytical = Analytical(chunk);
                if (chunk.length == 21)
                {
                    List<DataListModel> r = employees.map((e)
                        {
                            if (e.time == analytical.dataTime())
                            {
                                e.roll = double.parse(analytical.getRoll());
                                e.heading = double.parse(analytical.getHeading());
                                e.pitch = double.parse(analytical.getPitch());
                                return e;
                            }
                            return e;
                        }
                    ).toList();
                    setState(()
                        {
                            employees = r;
                            employeeDataSource = EmployeeDataSourceData(dataModels: r);

                            // 查找当前更新的数据在列表中的索引
                            int updatedRowIndex = -1;
                            for (int i = 0; i < employees.length; i++)
                            {
                                if (employees[i].time == analytical.dataTime())
                                {
                                    updatedRowIndex = i;
                                    break;
                                }
                            }
                            // 如果找到了被更新的行，滚动到该行
                            if (updatedRowIndex != -1)
                            {
                                WidgetsBinding.instance.addPostFrameCallback((_)
                                    {
                                        _dataGridController.scrollToRow(updatedRowIndex.toDouble(), canAnimate: true);
                                    }
                                );
                            }
                        }
                    );

                    // 检查是否已经收到了最后一条数据
                    bool isLastDataReceived = false;
                    if (employees.isNotEmpty)
                    {
                        // 获取employee列表中最后一条数据的时间
                        final lastDataTime = employees.last.roll;
                        // 检查是否与当前解析的数据时间匹配
                        if (employees.last.heading != null && employees.last.pitch != null)
                        {
                            isLastDataReceived = true;
                        }
                    }
                    // 如果是最后一条数据，关闭弹窗
                    if (isLastDataReceived)
                    {
                        EasyLoading.dismiss();
                        SmartDialog.showToast('数据接收完成');
                        // 取消订阅，停止监听
                        _lastValueSubscription?.cancel();
                        _lastValueSubscription = null;
                    }
                }
            }
            catch (e)
            {
                SmartDialog.showToast('数据解析错误: $e');
            }
        }
    }

    @override
    void dispose()
    {
        _lastValueSubscription?.cancel();

        targetCharacteristic = null;
        _lastValueSubscription = null;
        super.dispose();
    }

    // 孔口校正
    Widget get orificeButton => ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)) // 设置圆角为10
            )
        ),
        child:
        const Text('孔口校正', style: TextStyle(fontSize: 16, color: Colors.white)),
        onPressed: ()
        {
            // 检查蓝牙连接状态
            if (bluetooth.currentDevice == null || !bluetooth.isConnected)
            {
                SmartDialog.showToast('请先连接蓝牙设备');
                return;
            }

            // 显示孔口校正对话框
            showDialog(
                context: context,
                builder: (BuildContext context)
                {
                    return AlertDialog(
                        title: const Text("孔口校正"),
                        content: const Text("确定要执行孔口校正操作吗？"),
                        actions: <Widget>[
                            TextButton(
                                child: const Text("取消"),
                                onPressed: () => Navigator.of(context).pop()
                            ),
                            TextButton(
                                child: const Text("确定"),
                                onPressed: ()
                                {
                                    Navigator.of(context).pop();
                                    _performOrificeCorrection();
                                }
                            )
                        ]
                    );
                }
            );
        }
    );

    // 执行孔口校正操作
    Future<void> _performOrificeCorrection() async
    {
        if (targetCharacteristic == null)
        {
            SmartDialog.showToast('请先执行探管取数');
            return;
        }

        try
        {
            EasyLoading.show(status: '正在执行孔口校正...');

            // 这里添加孔口校正的具体逻辑，例如发送特定命令到设备
            await targetCharacteristic!.write([
                    0x68,
                    0x0C,
                    0x00,
                    0x74, // 假设这是孔口校正的命令代码
                    0x02,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x82
                ], withoutResponse: false);

            EasyLoading.dismiss();
            SmartDialog.showToast('孔口校正完成');
        }
        catch (e)
        {
            EasyLoading.dismiss();
            SmartDialog.showToast('孔口校正失败: $e');
        }
    }

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: const CustomAppBar('数据传输'),
            body: Container(
                color: const Color.fromRGBO(238, 239, 241, 0.8),
                child: Container(
                    // color: Colors.white,
                    margin: const EdgeInsets.only(
                        left: 10,
                        bottom: 10,
                        right: 10,
                        top: 10
                    ),
                    // padding: const EdgeInsets.all(10),
                    child: Column(
                        children: [
                            Container(
                                color: Colors.white,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10, left: 30, right: 30),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        // 可选：根据需要调整按钮间的间距
                                        children: [
                                            Text('矿区：$_mineString'),
                                            Text('工作面：$_workString'),
                                            Text('钻厂：$_factoryString'),
                                            Text('钻孔：$_drillingString'),
                                            Text('检测名称：$_name')
                                        ]
                                    )
                                )
                            ),
                            const SizedBox(
                                height: 10
                            ),
                            Expanded(
                                flex: 1,
                                child: Row(
                                    children: [
                                        Container(
                                            color: Colors.white,
                                            child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Column(
                                                    children: [
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.blueAccent,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                        Radius.circular(10)) // 设置圆角为10
                                                                )
                                                            ),
                                                            child: const Text('探管取数',
                                                                style: TextStyle(
                                                                    fontSize: 16, color: Colors.white)),
                                                            onPressed: ()
                                                            {
                                                                discoverServices(bluetooth.currentDevice);
                                                            }
                                                        ),
                                                        // orificeButton,
                                                        ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.blueAccent,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                        Radius.circular(10)) // 设置圆角为10
                                                                )
                                                            ),
                                                            child: const Text('数据保存',
                                                                style: TextStyle(
                                                                    fontSize: 16, color: Colors.white)),
                                                            onPressed: ()
                                                            {
                                                                // 将原始数据保存
                                                                for (var element in employees)
                                                                {
                                                                    element.repoId = _repoId;
                                                                    DatabaseHelper().updateDataList(element);
                                                                }
                                                                SmartDialog.showToast('数据保存成功');
                                                            }
                                                        )
                                                    ]
                                                ))
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                color: Colors.white,
                                                margin: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10
                                                ),
                                                child: SfDataGrid(
                                                    headerRowHeight: 40,
                                                    source: employeeDataSource,
                                                    controller: _dataGridController,
                                                    gridLinesVisibility: GridLinesVisibility.none,
                                                    columnWidthMode: ColumnWidthMode.fill,
                                                    columns: <GridColumn>[
                                                        GridColumn(
                                                            columnName: 'id',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(0.0),
                                                                alignment: Alignment.center,
                                                                color: Colors.black12,
                                                                // const Color.fromRGBO( 234, 236, 255, 1),
                                                                child: const Text(
                                                                    '序号',
                                                                    style: TextStyle(color: Colors.black)
                                                                )
                                                            )),
                                                        GridColumn(
                                                            columnName: 'time',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                color: Colors.black12,
                                                                // const Color.fromRGBO( 234, 236, 255, 1),
                                                                child: const Text(
                                                                    '时间',
                                                                    overflow: TextOverflow.ellipsis
                                                                ))),
                                                        GridColumn(
                                                            columnName: 'depth',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                color: Colors.black12,
                                                                // const Color.fromRGBO( 234, 236, 255, 1),
                                                                child: const Text(
                                                                    '深度',
                                                                    overflow: TextOverflow.ellipsis
                                                                ))),
                                                        GridColumn(
                                                            columnName: 'pitch',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                color: Colors.black12,
                                                                // const Color.fromRGBO( 234, 236, 255, 1),
                                                                child: const Text('俯仰角（°）'))),
                                                        GridColumn(
                                                            columnName: 'heading',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                color: Colors.black12,
                                                                // const Color.fromRGBO( 234, 236, 255, 1),
                                                                child: const Text(
                                                                    '方位角（°）',
                                                                    overflow: TextOverflow.ellipsis
                                                                )))
                                                    ]
                                                )
                                            ))
                                    ]
                                ))
                        ]
                    )
                )
            )
        );
    }

    Future<void> getDatabaseData() async
    {
        List<DataListModel> result =
            await DatabaseHelper().getDataListForRepoId(_repoId);

        setState(()
            {
                employees = result;
                employeeDataSource = EmployeeDataSourceData(dataModels: result);
            }
        );
    }
}

class EmployeeDataSourceData extends DataGridSource
{
    /// Creates the data source class with required details.
    EmployeeDataSourceData({required List<DataListModel> dataModels})
    {
        _employeeData = dataModels
            .asMap() // 将列表转换为 Map，key 为 index
            .entries // 获取键值对 (index, element)
            .map<DataGridRow>((entry) => DataGridRow(cells: [
                        DataGridCell<int>(columnName: 'id', value: entry.key + 1),
                        DataGridCell<String>(columnName: 'time', value: entry.value.time),
                        DataGridCell<Object>(
                            columnName: 'depth', value: entry.value.depth),
                        DataGridCell<Object>(
                            columnName: 'pitch', value: entry.value.pitch ?? ''),
                        DataGridCell<Object>(
                            columnName: 'heading', value: entry.value.heading ?? '')
                    ]))
            .toList();
    }

    List<DataGridRow> _employeeData = [];

    @override
    List<DataGridRow> get rows => _employeeData;

    @override
    DataGridRowAdapter buildRow(DataGridRow row)
    {
        return DataGridRowAdapter(
            cells: row.getCells().map<Widget>((e)
                {
                    return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.value.toString())
                    );
                }
            ).toList());
    }
}
