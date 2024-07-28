import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

class RepoModel {
  /// Creates the employee class with required details.
  RepoModel(this.id, this.name, this.mnTime);

  /// Id of an employee.
  final int id;

  final String name;

  final String mnTime;
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<RepoModel> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'designation', value: e.mnTime),
              DataGridCell<Widget>(
                columnName: 'actions',
                value: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text('测点数据'),
                      onPressed: () {
                        // 编辑按钮的操作
                        //print('Edit ${e.name}');
                      },
                    ),
                    TextButton(
                      child: const Text('原始数据'),
                      onPressed: () {
                        // 删除按钮的操作
                        print('Delete ${e.name}');
                      },
                    ),
                    TextButton(
                      child: const Text('删除'),
                      onPressed: () {
                        // 删除按钮的操作
                        print('Delete ${e.name}');
                      },
                    ),
                  ],
                ),
              ),
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
      if (e.columnName == 'actions') {
        return e.value;
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
