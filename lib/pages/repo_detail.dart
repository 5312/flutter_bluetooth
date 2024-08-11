import 'package:flutter/material.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/widgets/LineChartSample.dart';
import 'dart:math';

// 为 DataListModel 类添加扩展方法
extension DataListModelExtensions on DataListModel {
  // 上下偏差计算
  String calculateDesignPitch(double length, num pitchAngle) {
    // 计算 X 和 Y
    double x = length * cos(pitchAngle);
    double y = length * sin(pitchAngle);
    // 输出结果
    print('X: $x');
    print('Y: $y');
    return '${y.toString()},${x.toString()}';
  }

  // // 例如，更新宽度
  // Rectangle withWidth(double newWidth) {
  //   return Rectangle(newWidth, height);
  // }
}

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

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<void> getList() async {
    List<DataListModel> list =
        await DatabaseHelper().getDataListByRepoId(widget.row.id);

    List<DataListModel> tableData = modifyDesignPitch(list);
    setState(() {
      employees = tableData;
      employeeDataSource = EmployeeDataSource(employeeData: employees);
    });
  }

  // 修改表格数据中设计俯仰角为上下偏差值
  List<DataListModel> modifyDesignPitch(List<DataListModel> list) {
    for (var element in list) {
      String upDown = calculateDesignPitch(10, element.pitch!);
      print(upDown);
      // element.designPitch = upDown;
    }
    return list;
  }

  // 计算上下偏差
  // 设计曲线Y=L x sin（A）,X=L x cos（A），
  // L=钻杆长度，A=设计俯仰角
  String calculateDesignPitch(double length, num pitchAngle) {
    // 计算 X 和 Y
    double x = length * cos(pitchAngle);
    double y = length * sin(pitchAngle);
    // 输出结果
    print('X: $x');
    print('Y: $y');
    return '${y.toString()},${x.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.row.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfDataGrid(
              source: employeeDataSource,
              columnWidthMode: ColumnWidthMode.fill,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'id',
                    label: Container(
                        padding: const EdgeInsets.all(16.0),
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
                    columnName: 'pitch',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '俯仰角',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'roll',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '翻滚角（°）',
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
                GridColumn(
                    columnName: 'designPitch',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '上下偏差',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'designHeading',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '左右偏差',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          const Expanded(
              child: Row(
            children: [
              Expanded(child: LineChartSample9()),
              Expanded(child: LineChartSample9())
            ],
          ))
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
              DataGridCell<num>(columnName: 'pitch', value: e.pitch),
              DataGridCell<num>(columnName: 'roll', value: e.roll),
              DataGridCell<num>(columnName: 'heading', value: e.heading),
              DataGridCell<num>(
                  columnName: 'designPitch', value: e.designPitch),
              DataGridCell<num>(
                  columnName: 'designHeading', value: e.designHeading),
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
