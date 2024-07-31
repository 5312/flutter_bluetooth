import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

class DataModel {
  /// Creates the data model class with required details.
  final int id;
  final String timeData;
  final double deep;
  final double? inclination;
  final double? azimuth;

  DataModel({
    required this.id,
    required this.timeData,
    required this.deep,
    this.inclination,
    this.azimuth,
  });
}

class EmployeeDataSourceData extends DataGridSource {
  /// Creates the data source class with required details.
  EmployeeDataSourceData({required List<DataModel> dataModels}) {
    _employeeData = dataModels
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'timeData', value: e.timeData),
              DataGridCell<double>(columnName: 'deep', value: e.deep),
              DataGridCell<double>(
                  columnName: 'inclination', value: e.inclination ?? 0.0),
              DataGridCell<double>(
                  columnName: 'azimuth', value: e.azimuth ?? 0.0),
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
