import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

// 测点数据表
class DataListModel {
  /// Creates the data model class with required details.
  int? id;
  final String timeData;
  final double deep;
  final double? inclination;
  final double? azimuth;

  DataListModel({
    required this.id,
    required this.timeData,
    required this.deep,
    this.inclination,
    this.azimuth,
  });
}
