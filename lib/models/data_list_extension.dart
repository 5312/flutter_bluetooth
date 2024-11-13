import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ComputedXY {
  // static  d = (num s) => Decimal.parse(s.toString());
  // static  dn = (String s) => Decimal.parse(s);
  // static  df = (num d) => num.parse(d.toStringAsFixed(4));
  // static  df3 = (num d) => num.parse(d.toStringAsFixed(3));
  // 静态方法，不涉及实例字段
  static Decimal d(num s) => Decimal.parse(s.toString());

  static Decimal dn(String s) => Decimal.parse(s);

  static num df(num d) => num.parse(d.toStringAsFixed(4));

  static num df3(num d) => num.parse(d.toStringAsFixed(3));

  String truncateToThreeDecimalPlaces(double value) {
    // 将数字转换为字符串，并找到小数点的位置
    String valueStr = value.toString();
    int decimalIndex = valueStr.indexOf('.');

    // 处理小数部分
    String result;
    if (decimalIndex != -1 && decimalIndex + 3 < valueStr.length) {
      // 截取到小数点后三位，不进行四舍五入
      result = valueStr.substring(0, decimalIndex + 4); // +4 包括小数点后3位
    } else {
      result = valueStr; // 没有小数部分或小数位数不足三位
    }
    return result;
  }

  List<FlSpot> convertToFlSpot(List<Map<String, num>> designCurve) {
    List<FlSpot> spots = [];

    for (var point in designCurve) {
      double x = point['X']!.toDouble(); // 将 num 转换为 double
      double y = point['Y']!.toDouble();
      spots.add(FlSpot(x, y));
    }

    return spots;
  }

// 计算设计上下偏差曲线
  List<FlSpot> calculateDesignCurve(List<DataListModel> list, drillPipeLength) {
    List<Map<String, num>> designCurve = [];
    num preY = 0;
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drillPipeLength; // 6;
      num A = data.designPitch!; // 设计俯仰角
      // 计算X和Y坐标
      num x = data.depth;
      Decimal nowY = d(L) * d(sin(A * pi / 180));
      num dey = df(nowY.toDouble());
      num y1 = (dey + preY);
      num y = num.parse(y1.toStringAsFixed(4));
      designCurve.add({'X': x, 'Y': y});
      preY = y;
    }
    // design = convertToFlSpot(designCurve);
    return convertToFlSpot(designCurve);
  }

  // 计算实际上下偏差曲线
  List<FlSpot> calculateCoordinates(List<DataListModel> list, drillPipeLength) {
    num previousPitch = list[0].pitch!; // 用来存储上一个数据点的 pitch 值
    List<Map<String, num>> realCurve = [];
    num preY = 0;
    // for (var data in list) {
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drillPipeLength; // 6;//data.length;

      num A1 = data.pitch ?? 0;
      num A2 =
          (d(A1) + d(previousPitch)).toDouble(); // 当前 pitch 加上上一个数据点的 pitch
      num X = data.depth;
      num sinVal = (A2 / 2) * pi / 180;
      Decimal nowY = d(L) * d(sin(sinVal));
      Decimal strY = dn(nowY.toString()) + dn(preY.toString());
      num Y = df(strY.toDouble());
      realCurve.add({'X': X, 'Y': Y});
      previousPitch = A1; // 更新 previousPitch 为当前数据点的 pitch
      preY = Y;
    }
    // actual = convertToFlSpot(realCurve);
    return convertToFlSpot(realCurve);
  }

  // 计算设计左右偏差
  List<FlSpot> calculateDesignCurve2(
      List<DataListModel> list, drillPipeLength) {
    List<Map<String, num>> designCurve = [];
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      //num L = i == 0 ? 0 : drillPipeLength;
      //num A = data.designPitch ?? 0; // 设计俯仰角
      num designX = data.depth; //* cos(A); // 设计曲线的 X 坐标
      num designY = 0; // 设计曲线的 Y 坐标始终为 0
      designCurve.add({'X': designX, 'Y': designY});
    }
    // design2 = convertToFlSpot(designCurve);
    return convertToFlSpot(designCurve);
  }

  // 计算实际左右偏差
  List<FlSpot> calculateActualCurve2(
      List<DataListModel> list, drillPipeLength) {
    double previousPitch = list[0].designPitch!;
    double previousHeading = list[0].designHeading!;

    List<Map<String, double>> realCurve = [];
    double preY = 0;

    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drillPipeLength;
      double A1 = data.pitch ?? 0;

      // 当前俯仰角
      Decimal A2 = d(A1) + d(previousPitch);
      double B1 = data.heading!;
      double B2 = B1 + previousHeading;
      double B = data.designHeading!;

      num actualX = data.depth;

      // 计算实际曲线的 Y
      Decimal value1 = d(-L);
      Decimal value2 = d(cos((A2.toDouble() / 2) * pi / 180));
      Decimal value3 = d(sin((B2 / 2 - B) * pi / 180));

      // 计算实际偏差
      Decimal dey = value1 * value2 * value3;
      double cy = dey.toDouble();

      // 保留三位小数
      Decimal value4 = d(preY);
      Decimal ycheng = d(cy) + value4;

      // 转换结果为 double，并保留三位小数
      double actualY = ycheng.toDouble();
      actualY = double.parse(actualY.toStringAsFixed(3));

      realCurve.add({'X': actualX.toDouble(), 'Y': actualY});

      // 更新状态
      previousPitch = A1;
      previousHeading = B1;
      preY = actualY;
    }
    // actual2 = convertToFlSpot(realCurve);
    return convertToFlSpot(realCurve);
  }
}
