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
      onDelete: delete,
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
          onDelete: delete,
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

  Future<void> delete(int id) async {
    // await DatabaseHelper().deleteRepo(id);
    GetList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('数据报表'),
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
                          color: const Color.fromRGBO(234, 236, 255, 1),
                          alignment: Alignment.center,
                          child: const Text(
                            '序号',
                          ))),
                  GridColumn(
                      columnName: 'name',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: const Color.fromRGBO(234, 236, 255, 1),
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
                    width: 300,
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
}
