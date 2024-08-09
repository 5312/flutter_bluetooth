import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/database_helper.dart';

class Repo extends StatefulWidget {
  const Repo({Key? key}) : super(key: key);

  @override
  State<Repo> createState() => _RepoState();
}

class _RepoState extends State<Repo> {
  List<RepoModel> employees = <RepoModel>[];
  late RepoDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    GetList();
  }

  Future<void> GetList() async {
    List<RepoModel> list = await DatabaseHelper().getRepos();
    print(list.toString());
    setState(() {
      employees = list;
      employeeDataSource =
          RepoDataSource(employeeData: employees, onDelete: delete);
    });
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
