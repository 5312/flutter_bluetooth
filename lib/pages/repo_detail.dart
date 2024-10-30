import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/widgets/Line_chart_sample.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:decimal/decimal.dart';

// 测点数据
class RepoDetail extends StatefulWidget {
  final RepoModel row;

  const RepoDetail({Key? key, required this.row}) : super(key: key);

  @override
  State<RepoDetail> createState() => _RepoDetailState();
}

class _RepoDetailState extends State<RepoDetail> {
  // 表格数据
  List<DataListModel> employees = <DataListModel>[];
  late EmployeeDataSource employeeDataSource =
      EmployeeDataSource(employeeData: []);

  // 钻杆长度
  int drill_pipe_length = 0;

  // 上下偏差
  late List<FlSpot> design;
  late List<FlSpot> actual;

  // 左右偏差
  late List<FlSpot> design2;
  late List<FlSpot> actual2;

  @override
  void initState() {
    super.initState();
    design = [];
    actual = [];
    design2 = [];
    actual2 = [];
    getList();
  }

  Future<void> getList() async {
    List<DataListModel> list =
        await DatabaseHelper().getDataListByRepoId(widget.row.id!);
    List<RepoModel> repoItem =
        await DatabaseHelper().getReposForId(widget.row.id!);
    drill_pipe_length = repoItem[0].len;
    list.insert(
        0,
        DataListModel(
            id: 0,
            depth: 0,
            time: "0",
            pitch: list[0].pitch!,
            roll: 0,
            heading: list[0].heading!,
            repoId: 0,
            designPitch: list[0].designPitch,
            designHeading: list[0].designHeading));

    setState(() {
      employees = list;
      employeeDataSource = EmployeeDataSource(employeeData: employees);
      // 上下
      calculateDesignCurve(list);
      calculateCoordinates(list);

      // 左右
      calculateDesignCurve2(list);
      calculateActualCurve2(list);
    });
  }

  final d = (num s) => Decimal.parse(s.toString());
  final dn = (String s) => Decimal.parse(s);
  final df = (num d) => num.parse(d.toStringAsFixed(4));
  final df3 = (num d) => num.parse(d.toStringAsFixed(3));

  // 计算设计上下偏差曲线
  void calculateDesignCurve(List<DataListModel> list) {
    List<Map<String, num>> designCurve = [];
    num preY = 0;
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drill_pipe_length; // 6;
      num A = data.designPitch!; // 设计俯仰角
      // 计算X和Y坐标
      num x = data.depth;
      Decimal nowY = d(L) * d(sin(A * pi / 180));
      num dey = df(nowY.toDouble());
      num y = dey + preY;

      designCurve.add({'X': x, 'Y': y});
      preY = y;
    }
    design = convertToFlSpot(designCurve);
  }

  // 计算实际上下偏差曲线
  void calculateCoordinates(List<DataListModel> list) {
    num previousPitch = list[0].pitch!; // 用来存储上一个数据点的 pitch 值
    List<Map<String, num>> realCurve = [];
    num preY = 0;
    // for (var data in list) {
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drill_pipe_length; // 6;//data.length;

      num A1 = data.pitch ?? 0;
      num A2 =
          (d(A1) + d(previousPitch)).toDouble(); // 当前 pitch 加上上一个数据点的 pitch

      num X = data.depth;
      /////
      num SinVal = (A2 / 2) * pi / 180;

      Decimal nowY = d(L) * d(sin(SinVal));

      Decimal strY = dn(nowY.toString()) + dn(preY.toString());
      num Y = df(strY.toDouble());

      realCurve.add({'X': X, 'Y': Y});
      previousPitch = A1; // 更新 previousPitch 为当前数据点的 pitch
      preY = Y;
    }
    actual = convertToFlSpot(realCurve);
  }

  // 计算设计左右偏差
  void calculateDesignCurve2(List<DataListModel> list) {
    List<Map<String, num>> designCurve = [];
    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drill_pipe_length;

      num A = data.designPitch ?? 0; // 设计俯仰角

      num designX = data.depth; //* cos(A); // 设计曲线的 X 坐标
      num designY = 0; // 设计曲线的 Y 坐标始终为 0
      designCurve.add({'X': designX, 'Y': designY});
    }
    design2 = convertToFlSpot(designCurve);
  }

  // 计算实际左右偏差
  void calculateActualCurve2(List<DataListModel> list) {
    double previousPitch = list[0].designPitch!;
    double previousHeading = list[0].heading!;

    List<Map<String, double>> realCurve = [];
    double preY = 0;

    for (var i = 0; i < list.length; i++) {
      var data = list[i];
      num L = i == 0 ? 0 : drill_pipe_length;
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

    actual2 = convertToFlSpot(realCurve);
  }

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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    print('左右');
    print(actual2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.row.name),
      ),
      body: ListView(
        children: [
          Container(
            height: screenHeight * 0.5, // 占屏幕高度的40%,
            padding: const EdgeInsets.only(bottom: 30),
            child: SfDataGrid(
              headerRowHeight: 40,
              source: employeeDataSource,
              columnWidthMode: ColumnWidthMode.fill,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'id',
                    label: Container(
                        padding: const EdgeInsets.all(0.0),
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        alignment: Alignment.center,
                        child: const Text(
                          '序号',
                        ))),
                GridColumn(
                    columnName: 'time',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        alignment: Alignment.center,
                        child: const Text('时间'))),
                GridColumn(
                    columnName: 'depth',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '深度',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'pitch',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '俯仰角（°）',
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'heading',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(234, 236, 255, 1),
                        child: const Text(
                          '方位角（°）',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  const Text('上下偏差（上正下负）'),
                  // TODO 终孔左右偏差距离设计：最后一个点 实际- 设计
                  LineChartSample9(data: design, data2: actual)
                ],
              )),
              Expanded(
                  child: Column(
                children: [
                  const Text('左右偏差(左正右负)'),
                  // TODO 终孔上下偏差距离设计：最后一个点 实际- 设计
                  LineChartSample9(data: design2, data2: actual2)
                ],
              ))
            ],
          )
        ],
      ),
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<DataListModel> employeeData}) {
    _employeeData = employeeData
        .asMap() // 将列表转换为 Map，key 为 index
        .entries // 获取键值对 (index, element)
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.key + 1),
              DataGridCell<String>(columnName: 'time', value: e.value.time),
              DataGridCell<num>(columnName: 'depth', value: e.value.depth),
              DataGridCell<num>(columnName: 'pitch', value: e.value.pitch),
              DataGridCell<num>(columnName: 'heading', value: e.value.heading),
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
