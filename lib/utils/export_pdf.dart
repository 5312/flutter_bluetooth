import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';
import 'package:fl_chart/fl_chart.dart';

class ExportPdfPage {
  final RepoModel repoModelItem;
  final List<DataListModel> list;

  ExportPdfPage(this.repoModelItem, this.list);

  // 生成PDF文档
  Future<pw.Document> generatePdf() async {
    // 创建一个PDF文档
    final pdf = pw.Document();
    
    // 处理数据
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

    // 添加PDF页面
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // 标题
            pw.Header(
              level: 0,
              child: pw.Text('钻孔数据报表', 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))
            ),
            
            // 钻孔信息
            pw.Header(level: 1, text: '钻孔基本信息'),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('矿区'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.mine),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('工作面'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.work),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('钻场'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.factory),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('钻孔'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.drilling),
                    ),
                  ],
                ),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // 钻孔数据表格
            pw.Header(level: 1, text: '钻孔数据信息'),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(1),
              },
              children: [
                // 表头
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('序号')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('时间')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('深度')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('倾角')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('方位角')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('左右偏差')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('上下偏差')),
                  ],
                ),
                // 数据行
                ...List.generate(list.length, (index) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${index + 1}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].time}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].depth}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].pitch}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].heading}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${index < actual2.length ? actual2[index].y.toStringAsFixed(2) : ""}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${index < actual.length ? actual[index].y.toStringAsFixed(2) : ""}')),
                    ],
                  );
                }),
              ],
            ),
            
            // 可以在这里添加图表或其他信息（简化版本）
            pw.SizedBox(height: 30),
            pw.Paragraph(
              text: '生成时间: ${DateTime.now().toString()}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Paragraph(
              text: '本文档由系统自动生成',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    return pdf;
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

  // 保存PDF到用户选择的目录
  Future<void> savePdfToFile(pw.Document pdf) async {
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
        // 生成PDF文件名
        String fileName = "${repoModelItem.name}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final file = File('$selectedDirectory/$fileName');
        print("准备写入文件: ${file.path}");
        
        // 检查目录是否存在
        if (!await Directory(selectedDirectory).exists()) {
          print("目录不存在，尝试创建目录");
          await Directory(selectedDirectory).create(recursive: true);
        }
        
        // 保存PDF文件
        final pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
        
        print("文件写入成功");
        SmartDialog.showToast("PDF文件已成功保存到：${file.path}");
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

  void exportPdf() async {
    // 生成PDF数据
    pw.Document pdfDoc = await generatePdf();
    savePdfToFile(pdfDoc);
  }
} 