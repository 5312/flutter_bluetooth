import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

class DataModel {
  /// Creates the employee class with required details.
  DataModel(this.id, this.timeData, this.deep, this.inclination, this.azimuth);

  /// Id of an employee.
  final int id;

  /// Designation of an employee.
  final String timeData;

  ///  深度
  final double deep;

  /// Name of an employee. 倾角
  final double inclination;

  /// 方位角
  final double azimuth;
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<DataModel> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'timeData', value: e.timeData),
              DataGridCell<double>(columnName: 'deep', value: e.deep),
              DataGridCell<double>(
                  columnName: 'inclination', value: e.inclination),
              DataGridCell<double>(columnName: 'azimuth', value: e.azimuth),
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
