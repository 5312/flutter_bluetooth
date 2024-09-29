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
        await DatabaseHelper().getDataListByRepoId(widget.row.id);

    setState(() {
      employees = list;
      employeeDataSource = EmployeeDataSource(employeeData: employees);
      // 上下
      calculateDesignCurve(list);
      calculateActualCurve(list);
      // 左右
      calculateDesignCurve2(list);
      calculateActualCurve2(list);
    });
  }

  // 计算设计上下偏差曲线
  void calculateDesignCurve(List<DataListModel> list) {
    design = list
        .map(
            (e) => FlSpot(e.calculateDesignPitchX(), e.calculateDesignPitchY()))
        .toList();
    // cList 中Y 值 每一个向前累加
    design.insert(0, const FlSpot(0, 0));
    for (int i = 1; i < design.length; i++) {
      if (i == 0) {
        design[i] = FlSpot(design[i].x + 0, design[i].y + 0);
      } else {
        design[i] = FlSpot(
            design[i].x + design[i - 1].x, design[i].y + (design[i - 1].y));
      }
    }
  }

  // 计算实际上下偏差曲线
  void calculateActualCurve(List<DataListModel> list) {
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        list[i].pitch = list[i].designPitch! + list[i].pitch!;
      } else {
        list[i].pitch = list[i].pitch! + (list[i - 1].pitch!);
      }
    }
    actual = list.map((e) {
      // X=L x cos（（A1+A2）/2）） // /A1=实测俯仰角1（第一个点为设计角度），A2=实测俯仰角2
      // Y=L x sin(（A1+A2）/2）
      double radiansX = e.pitch! / 2;
      double radiansY = e.pitch! / 2;

      double x = e.length * cos(radiansX);
      double y = e.length * sin(radiansY);
      return FlSpot(x, y);
    }).toList();
    actual.insert(0, const FlSpot(0, 0));
    // y 累加计算
    for (int i = 0; i < actual.length; i++) {
      if (i == 0) {
        actual[i] = FlSpot(actual[i].x, actual[i].y + 0);
      } else {
        actual[i] = FlSpot(actual[i].x, actual[i].y + (actual[i - 1].y));
      }
    }
  }

  // 计算设计左右偏差
  void calculateDesignCurve2(List<DataListModel> list) {
    // Y=0，X=L x cos（A）
    design2 =
        list.map((e) => FlSpot(e.length * cos(e.designPitch!), 0)).toList();
    design2.insert(0, const FlSpot(0, 0));
    // y 累加计算
    for (int i = 0; i < design2.length; i++) {
      if (i == 0) {
        design2[i] = FlSpot(design2[i].x, design2[i].y + 0);
      } else {
        design2[i] = FlSpot(design2[i].x, design2[i].y + (design2[i - 1].y));
      }
    }
  }

  // 计算实际左右偏差
  void calculateActualCurve2(List<DataListModel> list) {
    // Y= -L x cos （（A1+A2）/2）x sin（（B1+B2）/2-B），X=L x cos（（A1+A2）/2））
    // 计算A1 + A2 , B1 + B2
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        list[i].pitch = list[i].designPitch! + list[i].pitch!;
        list[i].heading = list[i].designHeading! + list[i].heading!;
      } else {
        list[i].pitch = list[i].pitch! + (list[i - 1].pitch!);
        list[i].heading = list[i].heading! + (list[i - 1].heading!);
      }
    }
    actual2 = list.map((e) {
      double radiansX = e.pitch! / 2;

      double radiansY = e.heading! / 2 - e.designHeading!;

      double x = e.length * cos(radiansX);
      double y = -e.length * cos(radiansX) * sin(radiansY);
      return FlSpot(x, y);
    }).toList();
    actual2.insert(0, const FlSpot(0, 0));
    // y 累加计算
    for (int i = 0; i < actual2.length; i++) {
      if (i == 0) {
        actual2[i] = FlSpot(actual2[i].x, actual2[i].y + 0);
      } else {
        actual2[i] = FlSpot(actual2[i].x, actual2[i].y + (actual2[i - 1].y));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
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
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'time', value: e.time),
              DataGridCell<num>(columnName: 'length', value: e.length),
              DataGridCell<num>(columnName: 'pitch', value: e.pitch),
              DataGridCell<num>(columnName: 'heading', value: e.heading),
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
