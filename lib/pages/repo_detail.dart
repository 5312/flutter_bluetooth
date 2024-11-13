import 'package:flutter/material.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/widgets/Line_chart_sample.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';

//
// 测点数据
class RepoDetail extends StatefulWidget {
  final RepoModel row;

  const RepoDetail({Key? key, required this.row}) : super(key: key);

  @override
  State<RepoDetail> createState() => _RepoDetailState();
}

class _RepoDetailState extends State<RepoDetail> {
  // 表格数据
  List<DataListModel> employees = <DataListModel>[];
  late EmployeeDataSource employeeDataSource =
      EmployeeDataSource(employeeData: []);

  // 钻杆长度
  int drillPipeLength = 0;

  // 上下偏差
  late List<FlSpot> design;
  late List<FlSpot> actual;

  // 左右偏差
  late List<FlSpot> design2;
  late List<FlSpot> actual2;

  @override
  void initState() {
    super.initState();
    design = [];
    actual = [];
    design2 = [];
    actual2 = [];
    getList();
  }

  Future<void> getList() async {
    List<DataListModel> list =
        await DatabaseHelper().getDataListByRepoId(widget.row.id!);
    List<RepoModel> repoItem =
        await DatabaseHelper().getReposForId(widget.row.id!);
    drillPipeLength = repoItem[0].len;
    list.insert(
        0,
        DataListModel(
            id: 0,
            depth: 0,
            time: "0",
            pitch: list[0].pitch!,
            roll: 0,
            heading: list[0].heading!,
            repoId: 0,
            designPitch: list[0].designPitch,
            designHeading: list[0].designHeading));

    setState(() {
      employees = list;
      employeeDataSource = EmployeeDataSource(employeeData: employees);
      // 上下
      ComputedXY computed = ComputedXY();
      design = computed.calculateDesignCurve(list, drillPipeLength);
      actual = computed.calculateCoordinates(list, drillPipeLength);
      // 左右
      design2 = computed.calculateDesignCurve2(list, drillPipeLength);
      actual2 = computed.calculateActualCurve2(list, drillPipeLength);
    });
  }

  Widget leftRight() {
    // 最后一个点 实际 - 设计
    String formattedN = '0';
    if (actual2.isNotEmpty && design2.isNotEmpty) {
      double acy = actual2[actual2.length - 1].y;
      double desY = design2[design2.length - 1].y;
      double n = acy - desY;
      // 继续后续操作，比如格式化输出
      formattedN = n.toStringAsFixed(2);
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(
        left: 10,
        bottom: 10,
        right: 10,
        top: 5,
      ),
      padding: const EdgeInsets.all(10),
      height: 350,
      // 占屏幕高度的40%,
      child: Column(
        children: [
          const Text('左右偏差(左正右负)'),
          Text(
            '终孔左右偏差距离设计：$formattedN',
            style: const TextStyle(
              color: Colors.red, // 字体颜色
            ),
          ),
          Expanded(child: LineChartSample9(data: design2, data2: actual2)),
        ],
      ),
    );
  }

  Widget topBottom() {
    String formattedN = '0';
    if (actual2.isNotEmpty && design2.isNotEmpty) {
      double acy = actual[actual.length - 1].y;
      double desY = design[design.length - 1].y;
      double n = acy - desY;
      formattedN = n.toStringAsFixed(2); // 保留两位小数
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(
        left: 10,
        bottom: 5,
        right: 10,
        top: 5,
      ),
      // 设置四周的外边距
      padding: const EdgeInsets.all(10),
      height: 350,
      // 占屏幕高度的40%,
      child: Column(
        children: [
          const Text('上下偏差（上正下负）'),
          Text(
            '终孔上下偏差距离设计：$formattedN',
            style: const TextStyle(
              color: Colors.red, // 字体颜色
            ),
          ),
          Expanded(
            child: LineChartSample9(data: design, data2: actual),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.row.name),
      ),
      body: Container(
        color: const Color.fromRGBO(238, 239, 241, 0.8),
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              height: screenHeight * 0.5,
              margin: const EdgeInsets.only(
                left: 10,
                bottom: 5,
                right: 10,
                top: 10,
              ),
              padding: const EdgeInsets.all(10),
              child: SfDataGrid(
                headerRowHeight: 40,
                source: employeeDataSource,
                columnWidthMode: ColumnWidthMode.fill,
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'id',
                      label: Container(
                          padding: const EdgeInsets.all(0.0),
                          color: Colors.black12,
                          // const Color.fromRGBO( 234, 236, 255, 1),
                          alignment: Alignment.center,
                          child: const Text(
                            '序号',
                          ))),
                  GridColumn(
                      columnName: 'time',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.black12,
                          // const Color.fromRGBO( 234, 236, 255, 1),
                          alignment: Alignment.center,
                          child: const Text('时间'))),
                  GridColumn(
                      columnName: 'depth',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          color: Colors.black12,
                          // const Color.fromRGBO( 234, 236, 255, 1),
                          child: const Text(
                            '深度',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'pitch',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          color: Colors.black12,
                          // const Color.fromRGBO( 234, 236, 255, 1),
                          child: const Text(
                            '俯仰角（°）',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'heading',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          color: Colors.black12,
                          // const Color.fromRGBO( 234, 236, 255, 1),
                          child: const Text(
                            '方位角（°）',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ),
            ),
            // const SizedBox(height:5.0),
            topBottom(),
            leftRight(),
          ],
        ),
      ),
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<DataListModel> employeeData}) {
    _employeeData = employeeData
        .asMap() // 将列表转换为 Map，key 为 index
        .entries // 获取键值对 (index, element)
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.key + 1),
              DataGridCell<String>(columnName: 'time', value: e.value.time),
              DataGridCell<num>(columnName: 'depth', value: e.value.depth),
              DataGridCell<num>(columnName: 'pitch', value: e.value.pitch),
              DataGridCell<num>(columnName: 'heading', value: e.value.heading),
            ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
