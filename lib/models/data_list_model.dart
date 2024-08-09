// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:flutter/material.dart';

// 测点数据表
class DataListModel {
  int? id;
  String? time;
  // 俯仰角
  num? pitch;
  // 翻滚角
  num? roll;
  // 方位角
  num? heading;

  int? repoId;

  DataListModel({
    required this.id,
    this.time,
    required this.pitch,
    this.roll,
    this.heading,
    this.repoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'pitch': pitch,
      'roll': roll,
      'heading': heading,
    };
  }

  factory DataListModel.fromJson(Map<String, dynamic> json) {
    return DataListModel(
      id: json['id'],
      time: json['time'],
      pitch: json['pitch'],
      roll: json['roll'],
      heading: json['heading'],
    );
  }
}
