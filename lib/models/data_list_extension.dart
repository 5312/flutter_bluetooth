import 'package:bluetooth_mini/models/data_list_model.dart';

import 'dart:math';

// 为 DataListModel 类添加扩展方法
extension DataListModelExtensions on DataListModel {
  // 计算上下偏差
  // 设计曲线Y=L x sin（A）,X=L x cos（A），
  // L=钻杆长度，A=设计俯仰角
  // 上下偏差设计曲线计算
  String calculateDesignPitch() {
    // num length, num pitchAngle
    num l = length;
    num A = designPitch!;
    // 计算 X 和 Y
    double x = l * cos(A);
    double y = l * sin(A);
    return '${x.toString()},${y.toString()}';
  }

  // 计算设计曲线上下偏差x
  double calculateDesignPitchX() {
    // num length, num pitchAngle
    num l = length;
    num A = designPitch!;
    // 计算 X 和 Y
    double x = l * cos(A);
    return x;
  }

  // 计算设计曲线上下偏差y
  double calculateDesignPitchY() {
    // num length, num pitchAngle
    num l = length;
    num A = designPitch!;
    // 计算 X 和 Y
    double y = l * sin(A);
    return y;
  }

  // 实际曲线
  // Y=L x sin(（A1+A2）/2）, X=L x cos（（A1+A2）/2））
  //A1=实测俯仰角1（第一个点为设计角度），A2=实测俯仰角2
  // double actualX() {
  //   // num length, num pitchAngle
  //   num l = length;
  //   num A1 = designPitch!;
  //   num A2 = actualPitch!;
  //   // 计算 X 和 Y
  //   double x = l * cos((A1 + A2) / 2);
  //   return x;
  // }
}
