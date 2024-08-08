import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

// 报表 名称表
class RepoListModel {
  /// Creates the employee class with required details.

  /// Id of an employee.
  int? id;

  final String name;

  final String createTime;

  RepoListModel(
      {required this.id, required this.name, required this.createTime});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mnTime': createTime,
    };
  }

  factory RepoListModel.fromJson(Map<String, dynamic> json) {
    return RepoListModel(
      id: json['id'],
      name: json['name'],
      createTime: json['createTime'],
    );
  }
}
