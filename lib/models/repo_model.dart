import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/utils/export_pdf.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class RepoModel {
  /// Creates the employee class with required details.

  /// Id of an employee.
  final int? id;

  final String name;

  final String mnTime;

  final int len;

  final String mine;
  final String work;
  final String factory;
  final String drilling;

  RepoModel(
      {this.id,
      required this.name,
      required this.mnTime,
      required this.len,
      required this.mine,
      required this.work,
      required this.factory,
      required this.drilling});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mnTime': mnTime,
      'len': len,
      'mine': mine,
      'work': work,
      'factory': factory,
      'drilling': drilling,
    };
  }

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      id: json['id'],
      name: json['name'],
      mnTime: json['mnTime'],
      len: json['len'],
      mine: json['mine'],
      work: json['work'],
      factory: json['factory'],
      drilling: json['drilling'],
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class RepoDataSource extends DataGridSource {
  final void Function(int) onDelete; // 删除按钮回调
  final void Function(RepoModel) onDetail; // 详情按钮回调
  final void Function(RepoModel) onOrigin; // 原始数据按钮回调
  List<DataGridRow> _employeeData = [];
  @override
  List<DataGridRow> get rows => _employeeData;


  void onExport(int e) async {
    try {
      print("开始导出PDF，ID: $e");
      List<DataListModel> list = await DatabaseHelper().getDataListByRepoId(e);
      print("获取到数据点列表，数量: ${list.length}");
      
      List<RepoModel> repoItem = await DatabaseHelper().getReposForId(e);
      print("获取仓库数据: ${repoItem.length} 项");
      
      if (repoItem.isEmpty) {
        print("错误：未找到相关仓库数据");
        SmartDialog.showToast("错误：未找到相关数据");
        return;
      }
      
      ExportPdfPage ex = ExportPdfPage(repoItem[0], list);
      print("开始导出PDF");
      ex.exportPdf();
    } catch (e, stackTrace) {
      print("导出PDF时出错: $e");
      print("错误堆栈: $stackTrace");
      SmartDialog.showToast("导出PDF时出错: ${e.toString()}");
    }
  }

  /// Creates the employee data source class with required details.
  RepoDataSource({
    required List<RepoModel> employeeData,
    required this.onDelete,
    required this.onDetail,
    required this.onOrigin,
  }) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'designation', value: e.mnTime.toString()),
              DataGridCell<Widget>(
                columnName: 'actions',
                value: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text('测点数据'),
                      onPressed: () => onDetail(e),
                    ),
                    TextButton(
                      child: const Text('原始数据'),
                      onPressed: () => onOrigin(e),
                    ),
                    TextButton(
                      child: const Text('删除'),
                      onPressed: () => onDelete(e.id!),
                    ),
                    SizedBox(
                      width: 90, // 增加按钮宽度
                      child: TextButton(
                        child: const Text('导出PDF'),
                        onPressed: () => onExport(e.id!),
                      ),
                    ),
                  ],
                ),
              ),
            ]))
        .toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'actions') {
        return e.value;
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
