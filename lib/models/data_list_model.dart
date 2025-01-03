// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:flutter/material.dart';

// 测点数据表
class DataListModel {
  int? id;
  String? time;

  // 深度
  num depth;

  // （俯仰角）：描述物体绕横轴的旋转。可以理解为物体的“前后倾斜”。
  double? pitch;

  // （翻滚角）：描述物体绕纵轴的旋转。可以理解为物体的“左右倾斜”。
  double? roll;

  // （方位角）：描述物体绕垂直轴的旋转。可以理解为物体的“朝向”。
  double? heading;

  int? repoId;

  // 设计俯仰角
  double? designPitch;

  // 设计方位角
  double? designHeading;

  DataListModel({
    this.id,
    required this.depth,
    this.time,
    this.pitch,
    this.roll,
    this.heading,
    this.repoId,
    this.designPitch,
    this.designHeading,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'depth': depth,
      'pitch': pitch,
      'roll': roll,
      'heading': heading,
      'repoId': repoId,
      'designPitch': designPitch,
      'designHeading': designHeading,
    };
  }

  factory DataListModel.fromJson(Map<String, dynamic> json) {
    return DataListModel(
      id: json['id'],
      time: json['time'],
      depth: json['depth'],
      pitch: json['pitch'],
      roll: json['roll'],
      heading: json['heading'],
      repoId: json['repoId'],
      designPitch: json['designPitch'],
      designHeading: json['designHeading'],
    );
  }
}
