import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/widgets/Line_chart_sample.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';
import 'package:fl_chart/fl_chart.dart';

// 测点数据
class RepoDetail extends StatefulWidget {
  final RepoModel row;

  const RepoDetail({Key? key, required this.row}) : super(key: key);

  @override
  State<RepoDetail> createState() => _RepoDetailState();
}

class _RepoDetailState extends State<RepoDetail> {
  List<DataListModel> employees = <DataListModel>[];
  late EmployeeDataSource employeeDataSource =
      EmployeeDataSource(employeeData: []);

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
    list.insert(
        0,
        DataListModel(
            id: 0,
            length: 0,
            time: "0",
            pitch: 0,
            roll: 0,
            heading: 0,
            repoId: 0,
            designPitch: 0,
            designHeading: 0));

    setState(() {
      employees = list;
      employeeDataSource = EmployeeDataSource(employeeData: employees);
      // 上下
      calculateDesignCurve(list);
      calculateCoordinates(list);
      // calculateActualCurve(list);
      // 左右
      calculateDesignCurve2(list);
      calculateActualCurve2(list);
    });
  }

  // 计算设计上下偏差曲线
  void calculateDesignCurve(List<DataListModel> list) {
    List<Map<String, num>> designCurve = [];

    for (var data in list) {
      if (data.designPitch != null) {
        // 计算X和Y坐标
        num x = data.length * cos(data.designPitch!); // 角度转换为弧度
        num y = data.length * sin(data.designPitch!);

        designCurve.add({'X': x, 'Y': y});
      }
    }
    design = convertToFlSpot(designCurve);
  }

  List<FlSpot> convertToFlSpot(List<Map<String, num>> designCurve) {
    List<FlSpot> spots = [];

    for (var point in designCurve) {
      double x = point['X']!.toDouble(); // 将 num 转换为 double
      double y = point['Y']!.toDouble();
      spots.add(FlSpot(x, y));
    }

    return spots;
  }

  // 计算实际上下偏差曲线
  void calculateCoordinates(List<DataListModel> list) {
    num previousPitch = 0; // 用来存储上一个数据点的 pitch 值
    List<Map<String, num>> realCurve = [];

    for (var data in list) {
      num L = data.length;
      num A1 = data.pitch ?? 0;
      num A2 = A1 + previousPitch; // 当前 pitch 加上上一个数据点的 pitch

      num X = L * cos((A1 + A2) / 2);
      num Y = L * sin((A1 + A2) / 2);

      previousPitch = A1; // 更新 previousPitch 为当前数据点的 pitch
      realCurve.add({'X': X, 'Y': Y});
    }
    actual = convertToFlSpot(realCurve);
  }

  // 计算设计左右偏差
  void calculateDesignCurve2(List<DataListModel> list) {
    List<Map<String, num>> designCurve = [];
    for (var data in list) {
      num L = data.length; // 钻杆长度
      num A = data.designPitch ?? 0; // 设计俯仰角

      num designX = L * cos(A); // 设计曲线的 X 坐标
      num designY = 0; // 设计曲线的 Y 坐标始终为 0
      designCurve.add({'X': designX, 'Y': designY});
    }
    design2 = convertToFlSpot(designCurve);
  }

  // 计算实际左右偏差
  void calculateActualCurve2(List<DataListModel> list) {
    num previousPitch = 0; // 上一个数据点的 pitch
    num previousHeading = 0; // 上一个数据点的 heading
    List<Map<String, num>> realCurve = [];

    for (var data in list) {
      num L = data.length; // 钻杆长度
      num A1 = data.pitch ?? 0; // 当前俯仰角
      num A2 = A1 + previousPitch; // 当前俯仰角加上上一个数据点的俯仰角

      num B1 = data.heading ?? 0; // 当前方位角
      num B2 = B1 + previousHeading; // 当前方位角加上上一个数据点的方位角

      num B = data.designHeading ?? 0; // 设计方位角（你可以根据需求调整）

      // 实际曲线的 X 和 Y
      num actualX = L * cos((A1 + A2) / 2);
      num actualY = -L * cos((A1 + A2) / 2) * sin((B1 + B2) / 2 - B);

      previousPitch = A1; // 更新上一个 pitch
      previousHeading = B1; // 更新上一个 heading
      realCurve.add({'X': actualX, 'Y': actualY});
    }
    actual2 = convertToFlSpot(realCurve);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // print(design);
    print(actual);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.row.name),
      ),
      body: ListView(
        children: [
          Container(
            height: screenHeight * 0.5, // 占屏幕高度的40%,
            padding: const EdgeInsets.only(bottom: 30),
            child: SfDataGrid(
              headerRowHeight: 40,
              source: employeeDataSource,
              columnWidthMode: ColumnWidthMode.fill,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'id',
                    label: Container(
                        padding: const EdgeInsets.all(0.0),
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        alignment: Alignment.center,
                        child: const Text(
                          '序号',
                        ))),
                GridColumn(
                    columnName: 'time',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        alignment: Alignment.center,
                        child: const Text('时间'))),
                GridColumn(
                    columnName: 'length',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '钻杆长度',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'pitch',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '俯仰角（°）',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'heading',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '方位角（°）',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  const Text('上下偏差'),
                  LineChartSample9(data: design, data2: actual)
                ],
              )),
              Expanded(
                  child: Column(
                children: [
                  const Text('左右偏差'),
                  LineChartSample9(data: design2, data2: actual2)
                ],
              ))
            ],
          )
        ],
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
              DataGridCell<num>(columnName: 'length', value: e.value.length),
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
