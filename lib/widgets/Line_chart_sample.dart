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
    // 动态判断是否显示
    if (meta.max != null) {
      double range = meta.max - meta.min;
      // 根据数据范围动态调整显示间隔
      double interval = (range / 10).ceil().toDouble(); // 将范围分成约10个区间
      if (value % interval != 0) {
        return const SizedBox.shrink();
      }
    }
    
    final style = TextStyle(
      color: AppColors.contentColorBlue,
      fontWeight: FontWeight.bold,
      fontSize: min(16, 4 * chartWidth / 300), // 减小字体大小
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      angle: 45, // 旋转标签以节省空间
      child: Text(meta.formattedValue, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    // 动态判断是否显示
    if (meta.max != null) {
      double range = meta.max - meta.min;
      // 根据数据范围动态调整显示间隔
      double interval = (range / 8).ceil().toDouble(); // 将范围分成约8个区间
      if (value % interval != 0) {
        return const SizedBox.shrink();
      }
    }
    
    final style = TextStyle(
      color: AppColors.contentColorBlack,
      fontSize: min(16, 4 * chartWidth / 300), // 减小字体大小
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(value.toStringAsFixed(1), style: style),
    );
  }

  /// 动态计算 maxY
  double _getMaxY(List<FlSpot> data) {
    var maxVal = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return maxVal;
  }

  /// 动态计算 minY
  double _getMinY(List<FlSpot> data) {
    var minVal = data.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    return minVal;
  }

  @override
  Widget build(BuildContext context) {
    //  widget.data 从头添加一组数据
    if (widget.data.isEmpty || widget.data2.isEmpty) {
      return const Center(child: Text('没有数据可显示'));
    }
    print('min${widget.data[0]}');
    print('min${widget.data[widget.data.length - 1]}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LegendWidget(),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                bottom: 20,
                right: 20,
                top: 20,
              ),
              child: AspectRatio(
                aspectRatio: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return LineChart(
                      LineChartData(
                        maxY: ((_getMaxY([...widget.data, ...widget.data2]) * 1.1) / 1.0).ceil() * 1.0,
                        minY: ((_getMinY([...widget.data, ...widget.data2]) * 1.1) / 1.0).floor() * 1.0,
                        // 根据你的数据设置合适的值
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            maxContentWidth: 100,
                            getTooltipColor: (touchedSpot) => Colors.black,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots
                                  .map((LineBarSpot touchedSpot) {
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
                            dotData: const FlDotData(
                              show: true, // 设置为 true 以显示点
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) =>
                                  leftTitleWidgets(
                                      value, meta, constraints.maxWidth),
                              reservedSize: 100,
                              interval: 1.0,
                            ),
                            drawBelowEverything: true,
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) =>
                                  bottomTitleWidgets(
                                      value, meta, constraints.maxWidth),
                              reservedSize: 45, // 增加保留空间以适应旋转的标签
                              interval: 1.0,
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
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Colors.black26, //.withOpacity(1),
                            dashArray: [8, 2],
                            strokeWidth: 0.8,
                          ),
                          getDrawingVerticalLine: (_) => const FlLine(
                            color: Colors.black26,
                            dashArray: [8, 2],
                            strokeWidth: 0.8,
                          ),
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
          ),
        ),
      ],
    );
  }
}

class LegendWidget extends StatelessWidget {
  const LegendWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LegendItem(color: AppColors.contentColorPink, text: '设计曲线'),
          LegendItem(color: AppColors.contentColorGreen, text: '实际曲线'),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }
}
