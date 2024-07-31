import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

class TimeModel {
  /// Creates the employee class with required details.

  /// Id of an employee.
  final int id;

  /// Name of an employee.深度
  final String inclination;

  /// Designation of an employee.
  final String timeData;

  TimeModel(
      {required this.id, required this.inclination, required this.timeData});

  /// Create an Employee object from a JSON map.
  factory TimeModel.fromJson(Map<String, dynamic> json) {
    return TimeModel(
      id: json['id'],
      inclination: json['inclination'],
      timeData: json['timeData'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'inclination': inclination,
      'timeData': timeData
    };

    return data;
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<TimeModel> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.inclination),
              DataGridCell<String>(
                  columnName: 'designation', value: e.timeData),
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
