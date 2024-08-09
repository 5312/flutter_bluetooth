import 'package:flutter/material.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/widgets/LineChartSample.dart';

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
    GetList();
  }

  Future<void> GetList() async {
    List<DataListModel> list =
        await DatabaseHelper().getDataListByRepoId(widget.row.id);

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
                          '设计俯仰角',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'designRoll',
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
          const SizedBox(height: 10.0),
          Expanded(child: LineChartSample9())
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
              DataGridCell<num>(columnName: 'designRoll', value: e.designRoll),
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
