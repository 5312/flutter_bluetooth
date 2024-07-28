import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class Repo extends StatefulWidget {
  const Repo({Key? key}) : super(key: key);

  @override
  State<Repo> createState() => _RepoState();
}

class _RepoState extends State<Repo> {
  List<RepoModel> employees = <RepoModel>[];
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
      appBar: const CustomAppBar('数据报表'),
      // AppBar(
      //   title: const Text('数据报表'),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      // ),
      body: Column(
        children: [
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
                          color:const  Color.fromRGBO(234, 236, 255, 1),
                          alignment: Alignment.center,
                          child:const  Text(
                            '序号',
                          ))),
                  GridColumn(
                      columnName: 'name',
                      label:  Container(
                          padding:  const EdgeInsets.all(8.0),
                          color:  const Color.fromRGBO(234, 236, 255, 1),
                          alignment: Alignment.center,
                          child: const Text('名称'))),
                  GridColumn(
                      columnName: 'mnTime',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          color: const Color.fromRGBO(234, 236, 255, 1),
                          child: const Text(
                            '时间',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                    columnName: 'actions',
                    width:300 ,
                    label: Container(
                      padding: const EdgeInsets.all(0),
                      color: const Color.fromRGBO(234, 236, 255, 1),
                      alignment: Alignment.center,
                      child: const Text('操作'),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  List<RepoModel> getEmployeeData() {
    return [
      RepoModel(10001, '333.xml', 'C4:64:F3:49:87:9F'),
      RepoModel(10002, '333.xml', 'C4:64:F3:49:87:9F'),
    ];
  }
}
