import 'dart:io';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportXmlPage {
  final RepoModel repoModelItem;
  final List<DataListModel> list;

  ExportXmlPage(this.repoModelItem, this.list);

  // 示例：生成 XML 数据
  String generateXml() {
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
    ComputedXY computed = ComputedXY();
    List<FlSpot> design =
        computed.calculateDesignCurve(list, repoModelItem.len);
    List<FlSpot> actual =
        computed.calculateCoordinates(list, repoModelItem.len);
    // 左右
    List<FlSpot> design2 =
        computed.calculateDesignCurve2(list, repoModelItem.len);
    List<FlSpot> actual2 =
        computed.calculateActualCurve2(list, repoModelItem.len);

    final builder = xml.XmlBuilder();
    builder.processing(
        'xml', 'version="1.0" encoding="UTF-8" standalone="yes"'); // 添加 XML 声明
    builder.element('钻孔数据总表', nest: () {
      builder.element('钻孔信息', nest: () {
        builder.element('矿区', nest: repoModelItem.mine);
        builder.element('工作面', nest: repoModelItem.work);
        builder.element('钻场', nest: repoModelItem.factory);
        builder.element('钻孔', nest: repoModelItem.drilling);
      });
      builder.element('钻孔数据信息', nest: () {
        // 遍历 list 并生成 data 元素
        list.asMap().forEach((index, DataListModel data) {
          builder.element('data', nest: () {
            builder.element('序号', nest: index + 1 ?? '');
            builder.element('时间', nest: data.time ?? '');
            builder.element('深度', nest: data.depth ?? '');
            builder.element('倾角', nest: data.pitch ?? '');
            builder.element('方位角', nest: data.heading ?? '');
            builder.element('工具面向角', nest: '');
            builder.element('左右偏差', nest: actual2[index].y);
            builder.element('上下偏差', nest: actual[index].y);
          });
        });
      });
    });
    final document = builder.buildDocument();
    return document.toString(); // 转换为字符串
  }

  // 请求存储权限
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      // 对于 Android 10 及以上版本
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
      return false;
    }
    return true; // 在iOS上默认返回true
  }

  // 保存 XML 到用户选择的目录
  Future<void> saveXmlToFile(String xmlContent) async {
    try {
      print("检查存储权限...");
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        SmartDialog.showToast("无法获取存储权限，请在系统设置中授予权限");
        return;
      }

      print("开始选择保存目录...");
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      print("选择的目录: $selectedDirectory");

      if (selectedDirectory != null) {
        final file = File('$selectedDirectory/output.xml');
        print("准备写入文件: ${file.path}");
        
        // 检查目录是否存在
        if (!await Directory(selectedDirectory).exists()) {
          print("目录不存在，尝试创建目录");
          await Directory(selectedDirectory).create(recursive: true);
        }
        
        // 检查文件是否可写
        try {
          await file.writeAsString('test');
          await file.delete();
        } catch (e) {
          print("文件写入测试失败: $e");
          SmartDialog.showToast("无法写入到选择的目录，请检查权限或选择其他目录");
          return;
        }
        
        // 写入实际内容
        await file.writeAsString(xmlContent);
        print("文件写入成功");
        SmartDialog.showToast("XML 文件已成功保存到：${file.path}");
      } else {
        print("用户取消了目录选择");
        SmartDialog.showToast("操作已取消：没有选择目录。");
      }
    } catch (e, stackTrace) {
      print("保存文件时发生错误: $e");
      print("错误堆栈: $stackTrace");
      SmartDialog.showToast("保存失败：${e.toString()}");
    }
  }

  void exportXml() async {
    // 生成 XML 数据
    String xmlContent = generateXml();
    saveXmlToFile(xmlContent);
  }
}
