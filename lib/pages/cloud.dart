import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/cloud_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class Cloud extends StatefulWidget {
  const Cloud({Key? key}) : super(key: key);

  @override
  State<Cloud> createState() => _CloudState();
}

class _CloudState extends State<Cloud> {
  List<CloudModel> employees = <CloudModel>[];
  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  // 添加和保存按钮
  Widget allButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('全选', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 添加操作的逻辑
    },
  );

  //
  Widget batchButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('批量同步', style: TextStyle(fontSize: 16, color: Colors.blue)),
    onPressed: () {
      // 添加操作的逻辑
    },
  );
  Widget saveButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('一键同步', style: TextStyle(fontSize: 16, color: Colors.blue)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const CustomAppBar('同步云端'),
      body: Column(
        children: [
          Padding(
            padding:const EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // 可选：根据需要调整按钮间的间距
              children: [
                Row(
                  children: [
                    allButton,
                    const SizedBox(
                      width: 10,
                    ),
                    batchButton,
                  ],
                ),
                saveButton,
              ],
            ),
          ),
          const SizedBox(
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
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '序号',
                          ))),
                  GridColumn(
                      columnName: 'name',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text('名称'))),
                  GridColumn(
                      columnName: 'mnTime',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '时间',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'state',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '状态',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ))
        ],
      ),
    );
  }

  List<CloudModel> getEmployeeData() {
    return [
      CloudModel(10001, '333.xml', 'C4:64:F3:49:87:9F', '已同步'),
      CloudModel(10002, '333.xml', 'C4:64:F3:49:87:9F', '未同步'),
    ];
  }
}
