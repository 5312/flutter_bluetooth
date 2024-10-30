import 'package:bluetooth_mini/resources/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'dart:math';

// 上下偏差
class LineChartSample9 extends StatefulWidget {
  final List<FlSpot> data;
  final List<FlSpot> data2;

  const LineChartSample9({
    Key? key,
    required this.data,
    required this.data2,
  }) : super(key: key);

  @override
  State<LineChartSample9> createState() => _LineChartSample9State();
}

class _LineChartSample9State extends State<LineChartSample9> {
  @override
  void initState() {
    super.initState();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) {
      return Container();
    }
    final style = TextStyle(
      color: AppColors.contentColorBlue,
      fontWeight: FontWeight.bold,
      fontSize: min(18, 2 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(meta.formattedValue, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      color: AppColors.contentColorYellow,
      fontWeight: FontWeight.bold,
      fontSize: min(18, 5 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(meta.formattedValue, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  widget.data 从头添加一组数据
    if (widget.data.isEmpty || widget.data2.isEmpty) {
      return Center(child: Text('没有数据可显示'));
    }
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          bottom: 20,
          right: 20,
          top: 20,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return LineChart(
                LineChartData(
                  maxY: widget.data[widget.data.length - 1].y + 10,
                  // 根据你的数据设置合适的值
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      maxContentWidth: 100,
                      getTooltipColor: (touchedSpot) => Colors.black,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final textStyle = TextStyle(
                            color: touchedSpot.bar.gradient?.colors[0] ??
                                touchedSpot.bar.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          return LineTooltipItem(
                            '${touchedSpot.x}, ${touchedSpot.y.toStringAsFixed(2)}',
                            textStyle,
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    getTouchLineStart: (data, index) => 0,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      color: AppColors.contentColorPink,
                      spots: widget.data,
                      isCurved: true,
                      isStrokeCapRound: true,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                      dotData: const FlDotData(
                        show: true, // 设置为 true 以显示点
                      ),
                    ),
                    LineChartBarData(
                      color: AppColors.contentColorGreen,
                      spots: widget.data2,
                      isCurved: true,
                      isStrokeCapRound: true,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                      dotData: FlDotData(
                        show: true, // 设置为 true 以显示点
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            // 增加底部填充
                            child: Text(value.toStringAsFixed(2)), // 自定义格式
                          );
                        },
                        reservedSize: 80,
                      ),
                      drawBelowEverything: true,
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => bottomTitleWidgets(
                            value, meta, constraints.maxWidth),
                        reservedSize: 36,
                        interval: 1,
                      ),
                      drawBelowEverything: true,
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 5,
                    checkToShowHorizontalLine: (value) {
                      return value.toInt() == 0;
                    },
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.contentColorBlue.withOpacity(1),
                      dashArray: [8, 2],
                      strokeWidth: 0.8,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: AppColors.contentColorYellow.withOpacity(1),
                      dashArray: [8, 2],
                      strokeWidth: 0.8,
                    ),
                    checkToShowVerticalLine: (value) {
                      return value.toInt() == 0;
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.transparent),
                      bottom: BorderSide(color: Colors.black),
                      // BorderSide(color: AppColors.borderColor),
                      right: BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
