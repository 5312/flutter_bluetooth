import 'package:flutter/material.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';

// 测点数据
class RepoOriginal extends StatefulWidget {
  final RepoModel row;

  const RepoOriginal({Key? key, required this.row}) : super(key: key);

  @override
  State<RepoOriginal> createState() => _RepoOriginalState();
}

class _RepoOriginalState extends State<RepoOriginal> {
  List<DataListModel> employees = <DataListModel>[];
  late EmployeeDataSource employeeDataSource =
      EmployeeDataSource(employeeData: []);

  @override
  void initState() {
    super.initState();
    GetList();
  }

  Future<void> GetList() async {
    List<DataListModel> list =
        await DatabaseHelper().getDataListByRepoId(widget.row.id!);

    setState(() {
      employees = list;
      employeeDataSource = EmployeeDataSource(employeeData: employees);
    });
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
                    columnName: 'depth',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '深度',
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
                GridColumn(
                    columnName: 'designPitch',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '设计俯仰角',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'designHeading',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '设计方位角',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            ),
          ),
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
              DataGridCell<num>(columnName: 'depth', value: e.value.depth),
              DataGridCell<Object>(
                  columnName: 'pitch', value: e.value.pitch ?? ''),
              DataGridCell<Object>(
                  columnName: 'heading', value: e.value.heading ?? ""),
              DataGridCell<num>(
                  columnName: 'designPitch', value: e.value.designPitch),
              DataGridCell<num>(
                  columnName: 'designHeading', value: e.value.designHeading),
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
