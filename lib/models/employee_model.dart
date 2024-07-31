import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Employee {
  /// Id of an employee.
  final int id;

  /// Name of an employee.
  final double inclination;

  /// Designation of an employee.
  final double azimuth;

  final int? repoId;

  /// Creates the employee class with required details.
  // Employee(this.id, this.inclination, this.azimuth, this.repoId);
  Employee(
      {required this.id,
      required this.inclination,
      required this.azimuth,
      this.repoId});

  /// Convert an Employee object to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'inclination': inclination,
        'azimuth': azimuth,
        'repoId': repoId,
      };

  /// Create an Employee object from a JSON map.
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      inclination: json['inclination'],
      azimuth: json['azimuth'],
      repoId: json['repoId'],
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<Employee> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<double>(columnName: 'name', value: e.inclination),
              DataGridCell<double>(columnName: 'designation', value: e.azimuth),
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
