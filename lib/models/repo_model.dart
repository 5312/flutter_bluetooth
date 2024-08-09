import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

class RepoModel {
  /// Creates the employee class with required details.

  /// Id of an employee.
  final int id;

  final String name;

  final String mnTime;

  RepoModel({required this.id, required this.name, required this.mnTime});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mnTime': mnTime,
    };
  }

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      id: json['id'],
      name: json['name'],
      mnTime: json['mnTime'],
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class RepoDataSource extends DataGridSource {
  final void Function(int) onDelete; // 删除按钮回调
  final void Function(RepoModel) onDetail; // 详情按钮回调
  final void Function(RepoModel) onOrigin; // 原始数据按钮回调
  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  /// Creates the employee data source class with required details.
  RepoDataSource({
    required List<RepoModel> employeeData,
    required this.onDelete,
    required this.onDetail,
    required this.onOrigin,
  }) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'designation', value: e.mnTime.toString()),
              DataGridCell<Widget>(
                columnName: 'actions',
                value: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text('测点数据'),
                      onPressed: () => onDetail(e),
                    ),
                    TextButton(
                      child: const Text('原始数据'),
                      onPressed: () => onOrigin(e),
                    ),
                    TextButton(
                      child: const Text('删除'),
                      onPressed: () => onDelete(e.id),
                    ),
                  ],
                ),
              ),
            ]))
        .toList();
  }

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
