import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/time_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class TimeOut extends StatefulWidget {
  const TimeOut({Key? key}) : super(key: key);

  @override
  State<TimeOut> createState() => _TimeOutState();
}

class _TimeOutState extends State<TimeOut> {
  List<TimeModel> employees = <TimeModel>[];
  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  // 定时同步按钮
  Widget timeButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(242, 243, 247, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child: const Text('定时同步',
        style:
            TextStyle(fontSize: 16, color: Color.fromRGBO(147, 153, 177, 1))),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 定点测量
  Widget fixedPointButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('定点测量', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 删除末尾数据
  Widget deletePopButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child: const Text('删除末尾数据',
        style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('定时同步'),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // 可选：根据需要调整按钮间的间距
              children: [
                Text('矿区：1'),
                Text('工作圈：1'),
                Text('钻厂：1'),
                Text('钻孔：1'),
                Text('检测名称：66'),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      width: 200,
                      child: Column(
                        children: [
                          Text('深度信息：0'),
                          Text('累计时间：00:00:00'),
                          timeButton,
                          fixedPointButton,
                          deletePopButton
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: SfDataGrid(
                        source: employeeDataSource,
                        gridLinesVisibility: GridLinesVisibility.none,
                        columnWidthMode: ColumnWidthMode.fill,
                        columns: <GridColumn>[
                          GridColumn(
                              columnName: 'id',
                              label: Container(
                                padding: EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                color: Color.fromRGBO(234, 236, 255, 1),
                                child: Text(
                                  '序号',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                          GridColumn(
                              columnName: 'inclination',
                              label: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(234, 236, 255, 1),
                                  child: Text('深度/m'))),
                          GridColumn(
                              columnName: 'azimuth',
                              label: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(234, 236, 255, 1),
                                  child: Text(
                                    '时间',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                        ],
                      ))
                ],
              ))
        ],
      ),
    );
  }

  List<TimeModel> getEmployeeData() {
    return [
      TimeModel(10001, 0.2, '00:04:02'),
      TimeModel(10002, 0.2, '00:04:02'),
      // TimeModel(10002, 0.2, '00:04:02'),
      // TimeModel(10002, 0.2, '00:04:02'),
    ];
  }
}
