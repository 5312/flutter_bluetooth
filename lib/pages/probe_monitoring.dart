import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/employee_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class Probe extends StatefulWidget {
  const Probe({Key? key}) : super(key: key);

  @override
  _ProbeState createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  // 添加和保存按钮
  Widget addButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child: const Text('储存', style: TextStyle(fontSize: 16, color: Colors.blue)),
    onPressed: () {
      // 添加操作的逻辑
    },
  );

  Widget saveButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('保存', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  CustomAppBar('探管检测'),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // 可选：根据需要调整按钮间的间距
              children: [
                addButton,
                SizedBox(
                  width: 10,
                ),
                saveButton,
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
              flex: 1,
              child: SfDataGrid(
                source: employeeDataSource,
                columnWidthMode: ColumnWidthMode.fill,
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'id',
                      label: Container(
                          padding: EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: Text(
                            '序号',
                          ))),
                  GridColumn(
                      columnName: 'inclination',
                      label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text('倾角/'))),
                  GridColumn(
                      columnName: 'azimuth',
                      label: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Text(
                            '方位角/°',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ))
        ],
      ),
    );
  }

  List<Employee> getEmployeeData() {
    return [
      Employee(10001, 0.2, 4.11),
      Employee(10002, 0.2, 4.11),
    ];
  }
}
