import 'dart:io';
import 'package:xml/xml.dart' as xml;
import 'package:file_picker/file_picker.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // 保存 XML 到用户选择的目录
  Future<void> saveXmlToFile(String xmlContent) async {
    try {
      // 通过文件选择器打开目录选择框
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        // 在用户选择的目录路径下创建并保存 XML 文件
        final file = File('$selectedDirectory/output.xml');
        await file.writeAsString(xmlContent);
        // print('XML 文件已保存到：${file.path}');
        // 显示保存成功的 Toast 消息
        Fluttertoast.showToast(
          msg: "XML 文件已成功保存到：${file.path}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // 显示未选择目录的提示
        Fluttertoast.showToast(
          msg: "操作已取消：没有选择目录。",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print(e);
      // 捕获任何保存过程中出现的异常并提示错误信息
      // 捕获保存过程中出现的异常并显示错误提示
      Fluttertoast.showToast(
        msg: "保存失败：$e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void exportXml() async {
    // 生成 XML 数据
    String xmlContent = generateXml();
    saveXmlToFile(xmlContent);
  }
}
