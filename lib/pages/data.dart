import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class DataTransmission extends StatefulWidget {
  const DataTransmission({Key? key}) : super(key: key);

  @override
  State<DataTransmission> createState() => _DataTransmissionState();
}

class _DataTransmissionState extends State<DataTransmission> {
  List<DataModel> employees = <DataModel>[];
  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  // 探管取数
  Widget numberButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('探管取数', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 数据同步
  Widget dataButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('数据同步', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 孔口校正
  Widget orificeButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('孔口校正', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 数据保存
  Widget dataSaveButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('数据保存', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('数据传输'),
      body: Column(
        children: [
          Padding(
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
          SizedBox(
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
                          numberButton,
                          dataButton,
                          orificeButton,
                          dataSaveButton,
                          const Padding(
                            padding: EdgeInsets.only(
                              top:10,
                              left:10,
                              right:10
                            ),
                            child: Text(
                              '数据传输总数： 7',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black38),
                            ),
                          )
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
                              columnName: 'timeData',
                              label: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(234, 236, 255, 1),
                                  child: Text(
                                    '时间',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                          GridColumn(
                              columnName: 'deep',
                              label: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(234, 236, 255, 1),
                                  child: Text('深度/m'))),
                          GridColumn(
                              columnName: 'inclination',
                              label: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(234, 236, 255, 1),
                                  child: Text(
                                    '倾角/°',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                          GridColumn(
                              columnName: 'azimuth',
                              label: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(234, 236, 255, 1),
                                  child: Text(
                                    '方位角/°',
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

  List<DataModel> getEmployeeData() {
    return [
      DataModel(10001, '00:04:02', 3.0, 0.2, 4.11),
      DataModel(10002, '00:04:02', 3.0, 0.2, 4.11),
    ];
  }
}
