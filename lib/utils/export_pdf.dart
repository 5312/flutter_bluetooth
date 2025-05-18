import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/models/data_list_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ExportPdfPage {
  final RepoModel repoModelItem;
  final List<DataListModel> list;

  ExportPdfPage(this.repoModelItem, this.list);

  // 生成PDF文档
  Future<pw.Document> generatePdf() async {
    try {
      // 创建一个PDF文档
      final pdf = pw.Document();
      
      print("准备加载字体文件...");
      try {
        // 加载中文字体 - 尝试不同的加载方式
        try {
          // 方式1：使用assets路径
          print("尝试方式1: 使用assets路径加载Noto Sans SC字体");
          final fontData = await rootBundle.load('assets/fonts/NotoSansSC-VariableFont_wght.ttf');
          print("Noto Sans SC字体加载成功，大小: ${fontData.lengthInBytes} 字节");
          final ttf = pw.Font.ttf(fontData);
          print("Noto Sans SC字体对象创建成功");
          return _buildPdfWithFont(pdf, ttf);
        } catch (e) {
          print("方式1加载失败: $e");
          
          try {
            // 方式2：使用另一种字体
            print("尝试方式2: 使用assets路径加载青鸟华光简美黑字体");
            final fontData = await rootBundle.load('assets/fonts/QingNiaoHuaGuangJianMeiHei-2.ttf');
            print("青鸟华光简美黑字体加载成功，大小: ${fontData.lengthInBytes} 字节");
            final ttf = pw.Font.ttf(fontData);
            print("青鸟华光简美黑字体对象创建成功");
            return _buildPdfWithFont(pdf, ttf);
          } catch (e) {
            print("方式2加载失败: $e");
            
            // 方式3：使用系统内置字体
            print("尝试方式3: 创建不包含字体的PDF");
            print("所有字体加载失败，尝试创建未嵌入字体的PDF...");
            
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
                
            // 使用ASCII编码防止中文乱码的PDF
            pdf.addPage(
              pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                margin: const pw.EdgeInsets.all(32),
                build: (pw.Context context) {
                  return [
                    pw.Header(level: 0, text: "Drilling Data Report"),
                    pw.Paragraph(text: "Mine: ${repoModelItem.mine}"),
                    pw.Paragraph(text: "Work: ${repoModelItem.work}"),
                    pw.Paragraph(text: "Factory: ${repoModelItem.factory}"),
                    pw.Paragraph(text: "Drilling: ${repoModelItem.drilling}"),
                    pw.Paragraph(text: "Up-Down Final Deviation: ${(actual.last.y - design.last.y).toStringAsFixed(2)}"),
                    pw.Paragraph(text: "Left-Right Final Deviation: ${(actual2.last.y - design2.last.y).toStringAsFixed(2)}"),
                    pw.Paragraph(text: "Data Points: ${list.length}"),
                    pw.Paragraph(text: "Generation Time: ${DateTime.now().toString()}"),
                  ];
                },
              ),
            );
            return pdf;
          }
        }
      } catch (fontError, fontStack) {
        print("字体加载或PDF创建过程中出错: $fontError");
        print("字体错误堆栈: $fontStack");
        
        // 使用ASCII编码防止中文乱码的简单版本PDF
        print("尝试创建不使用中文的简化版PDF...");
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context context) {
              return [
                pw.Header(level: 0, text: "Drilling Data Report"),
                pw.Paragraph(text: "Error loading Chinese font. Generated simple report."),
                pw.Paragraph(text: "Mine: ${repoModelItem.mine}"),
                pw.Paragraph(text: "Work: ${repoModelItem.work}"),
                pw.Paragraph(text: "Factory: ${repoModelItem.factory}"),
                pw.Paragraph(text: "Drilling: ${repoModelItem.drilling}"),
                pw.Paragraph(text: "Data Points: ${list.length}"),
                pw.Paragraph(text: "Generation Time: ${DateTime.now().toString()}"),
              ];
            },
          ),
        );
        return pdf;
      }
    } catch (e, stackTrace) {
      print("generatePdf方法出现严重错误: $e");
      print("错误堆栈: $stackTrace");
      // 创建一个错误报告PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text("Error generating PDF: ${e.toString()}")
            );
          }
        )
      );
      return pdf;
    }
  }
  
  // 构建线性图表
  pw.Widget _buildLineChart(List<FlSpot> designData, List<FlSpot> actualData, pw.Font ttf) {
    // 查找最大和最小值，确定图表范围
    final allPoints = [...designData, ...actualData];
    final maxY = allPoints.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.1;
    final minY = allPoints.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 1.1;
    
    // 设置图表的横轴数据点数
    final xAxisPoints = designData.length;
    
    // 构建图表
    return pw.Container(
      height: 200,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            List.generate(xAxisPoints, (index) => '${designData[index].x.toInt()}'),
            marginStart: 30,
            marginEnd: 30,
            // 如果数据点太多，则只显示部分标签
            textStyle: pw.TextStyle(font: ttf, fontSize: 6),
          ),
          yAxis: pw.FixedAxis(
            [minY.floor(), 0, maxY.ceil()],
            format: (v) => v.toStringAsFixed(1),
            divisions: true,
            textStyle: pw.TextStyle(font: ttf, fontSize: 6),
          ),
        ),
        datasets: [
          // 设计曲线
          pw.LineDataSet(
            legend: '设计曲线',
            drawPoints: true,
            isCurved: true,
            pointSize: 1,
            color: PdfColors.pink,
            data: List.generate(
              designData.length, 
              (index) => pw.LineChartValue(
                index.toDouble(), 
                designData[index].y
              )
            ),
          ),
          // 实际曲线
          pw.LineDataSet(
            legend: '实际曲线',
            drawPoints: true,
            isCurved: true,
            pointSize: 1,
            color: PdfColors.green,
            data: List.generate(
              actualData.length, 
              (index) => pw.LineChartValue(
                index.toDouble(), 
                actualData[index].y
              )
            ),
          ),
        ],
      ),
    );
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
      print("开始保存PDF文件过程...");
      print("检查存储权限...");
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        print("未获得存储权限");
        SmartDialog.showToast("无法获取存储权限，请在系统设置中授予权限");
        return;
      }
      print("存储权限已获取");

      print("开始选择保存目录...");
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      print("选择的目录: $selectedDirectory");

      if (selectedDirectory != null) {
        // 生成PDF文件名
        String fileName = "${repoModelItem.name}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        String filePath = '$selectedDirectory/$fileName';
        print("准备写入文件路径: $filePath");
        
        final file = File(filePath);
        
        // 检查目录是否存在
        if (!await Directory(selectedDirectory).exists()) {
          print("目录不存在，尝试创建目录: $selectedDirectory");
          await Directory(selectedDirectory).create(recursive: true);
          print("目录创建成功");
        } else {
          print("目录已存在");
        }
        // 检查文件是否已存在
        if (await file.exists()) {
          print("文件已存在，将被覆盖");
        }
        
        // 保存PDF文件
        print("生成PDF字节数据...");
        final pdfBytes = await pdf.save();
        print("PDF字节数据生成完成，大小: ${pdfBytes.length} 字节");
        
        print("开始写入文件...");
        await file.writeAsBytes(pdfBytes);
        print("文件写入完成");
        
        SmartDialog.showToast("PDF文件已成功保存到：${file.path}");
      } else {
        print("用户取消了目录选择");
        SmartDialog.showToast("操作已取消：没有选择目录。");
      }
    } catch (e, stackTrace) {
      print("保存文件时发生严重错误: $e");
      print("错误堆栈: $stackTrace");
      SmartDialog.showToast("保存失败：${e.toString()}");
      
      // 尝试使用备用路径保存
      try {
        print("尝试使用应用文档目录保存...");
        final directory = await getApplicationDocumentsDirectory();
        final String backupPath = directory.path;
        print("应用文档目录: $backupPath");
        
        final String fileName = "backup_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final File file = File('$backupPath/$fileName');
        
        print("保存PDF到备用路径: ${file.path}");
        final pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
        
        print("备用路径保存成功");
        SmartDialog.showToast("PDF已保存到应用备用目录：${file.path}");
      } catch (backupError) {
        print("备用保存也失败: $backupError");
        SmartDialog.showToast("所有保存尝试均失败，请检查应用权限");
      }
    }
  }

  // 使用加载的字体构建PDF
  Future<pw.Document> _buildPdfWithFont(pw.Document pdf, pw.Font ttf) async {
    // 处理数据
    print("准备处理数据...");
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
    print("数据初始化完成");
    
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
    print("图表数据计算完成");

    // 添加PDF页面
    print("开始创建PDF页面...");
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
                  style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold))
            ),
            
            // 钻孔信息
            pw.Header(level: 1, child: pw.Text('钻孔基本信息', style: pw.TextStyle(font: ttf))),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('矿区', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.mine, style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('工作面', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.work, style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('钻场', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.factory, style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('钻孔', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.drilling, style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
                // 新增一行，显示检测名称、设计俯仰角、设计方位角、钻杆长度
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('检测名称', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.name, style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('钻杆长度', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(repoModelItem.len.toString(), style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('设计俯仰角', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(list[0].designPitch?.toStringAsFixed(2) ?? '', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('设计方位角', style: pw.TextStyle(font: ttf)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(list[0].designHeading?.toStringAsFixed(2) ?? '', style: pw.TextStyle(font: ttf)),
                    ),
                  ],
                ),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // 钻孔数据表格 - 测点数据表格
            pw.Header(level: 1, child: pw.Text('测点数据信息', style: pw.TextStyle(font: ttf))),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // 表头
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('序号', style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('检测名称', style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('时间', style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('深度', style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('俯仰角（°）', style: pw.TextStyle(font: ttf))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('方位角（°）', style: pw.TextStyle(font: ttf))),
                  ],
                ),
                // 数据行
                ...List.generate(list.length, (index) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${index + 1}', style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(repoModelItem.name, style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].time}', style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].depth}', style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].pitch}', style: pw.TextStyle(font: ttf))),
                      pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('${list[index].heading}', style: pw.TextStyle(font: ttf))),
                    ],
                  );
                }),
              ],
            ),
            
            pw.SizedBox(height: 30),
            
            // 上下偏差图表
            pw.Header(level: 2, child: pw.Text('上下偏差（上正下负）', style: pw.TextStyle(font: ttf))),
            // 终孔偏差信息
            pw.Paragraph(
              text: '终孔上下偏差距离设计：${(actual.last.y - design.last.y).toStringAsFixed(2)}',
              style: pw.TextStyle(font: ttf, color: PdfColors.red, fontSize: 12),
            ),
            _buildLineChart(design, actual, ttf),
            
            pw.SizedBox(height: 20),
            
            // 左右偏差图表
            pw.Header(level: 2, child: pw.Text('左右偏差（左正右负）', style: pw.TextStyle(font: ttf))),
            pw.Paragraph(
              text: '终孔左右偏差距离设计：${(actual2.last.y - design2.last.y).toStringAsFixed(2)}',
              style: pw.TextStyle(font: ttf, color: PdfColors.red, fontSize: 12),
            ),
            _buildLineChart(design2, actual2, ttf),
            
            pw.SizedBox(height: 30),
            pw.Paragraph(
              text: '生成时间: ${DateTime.now().toString()}',
              style: pw.TextStyle(font: ttf, fontSize: 10),
            ),
            pw.Paragraph(
              text: '本文档由系统自动生成',
              style: pw.TextStyle(font: ttf, fontSize: 10),
            ),
          ];
        },
      ),
    );
    print("PDF页面创建完成");
    
    return pdf;
  }

  void exportPdf() async {
    try {
      // 显示加载提示
      SmartDialog.showToast("开始生成PDF...");
      SmartDialog.showLoading(msg: "正在生成PDF...");
      
      print("开始加载字体...");
      // 生成PDF数据
      pw.Document pdfDoc = await generatePdf();
      print("PDF生成成功，准备保存...");
      
      // 隐藏加载提示
      SmartDialog.dismiss();
      
      // 保存PDF文件
      savePdfToFile(pdfDoc);
    } catch (e, stackTrace) {
      print("PDF导出过程中出现错误: $e");
      print("错误堆栈: $stackTrace");
      SmartDialog.dismiss();
      SmartDialog.showToast("生成PDF失败：${e.toString()}");
    }
  }
}