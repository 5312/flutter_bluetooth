import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/pages/repo_detail.dart';
import 'package:bluetooth_mini/pages/repo_original.dart';

class Repo extends StatefulWidget {
  const Repo({Key? key}) : super(key: key);

  @override
  State<Repo> createState() => _RepoState();
}

class _RepoState extends State<Repo> {
  List<RepoModel> employees = <RepoModel>[];
  late RepoDataSource employeeDataSource = RepoDataSource(
      employeeData: [],
      onDelete: showDeleteConfirmDialog1,
      onDetail: onDetail,
      onOrigin: onOrigin);

  @override
  void initState() {
    super.initState();
    GetList();
  }

  Future<void> GetList() async {
    List<RepoModel> list = await DatabaseHelper().getRepos();
    setState(() {
      employees = list;
      employeeDataSource = RepoDataSource(
          employeeData: employees,
          onDelete: showDeleteConfirmDialog1,
          onDetail: onDetail,
          onOrigin: onOrigin);
    });
  }

  Future<void> onDetail(RepoModel row) async {
    // 导航至详细页面
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => RepoDetail(row: row),
        settings: const RouteSettings(name: '/RepoDetail'));
    Navigator.of(context).push(route);
  }

  Future<void> onOrigin(RepoModel row) async {
    // 导航至详细页面
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => RepoOriginal(row: row),
        settings: const RouteSettings(name: '/RepoOriginal'));
    Navigator.of(context).push(route);
  }

// 弹出对话框
  Future<bool?> showDeleteConfirmDialog1(int id) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("您确定要删除当前文件吗?"),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: Text("删除"),
              onPressed: () async {
                await DatabaseHelper().deleteRepo(id);
                GetList();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('数据报表'),
      body: Container(
        color: const Color.fromRGBO(238, 239, 241, 0.8),
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.only(
            left: 10,
            bottom: 10,
            right: 10,
            top: 10,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: SfDataGrid(
                    source: employeeDataSource,
                    headerRowHeight: 40,
                    columnWidthMode: ColumnWidthMode.fill,
                    columns: <GridColumn>[
                      GridColumn(
                          columnName: 'id',
                          label: Container(
                              padding: const EdgeInsets.all(0.0),
                              color: Colors.black12,
                              // const Color.fromRGBO( 234, 236, 255, 1),
                              alignment: Alignment.center,
                              child: const Text(
                                '序号',
                              ))),
                      GridColumn(
                          columnName: 'name',
                          label: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.black12,
                              // const Color.fromRGBO( 234, 236, 255, 1),
                              alignment: Alignment.center,
                              child: const Text('名称'))),
                      GridColumn(
                          columnName: 'mnTime',
                          label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              color: Colors.black12,
                              // const Color.fromRGBO( 234, 236, 255, 1),
                              child: const Text(
                                '时间',
                                overflow: TextOverflow.ellipsis,
                              ))),
                      GridColumn(
                        columnName: 'actions',
                        width: 300,
                        label: Container(
                          padding: const EdgeInsets.all(0),
                          color: Colors.black12,
                          // const Color.fromRGBO( 234, 236, 255, 1),
                          alignment: Alignment.center,
                          child: const Text('操作'),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
