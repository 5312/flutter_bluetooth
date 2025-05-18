import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:flutter/services.dart';

class DrillTrackServer {
  final String name;
  final String ipAddress;
  final int httpPort;
  final int discoveryPort;
  
  DrillTrackServer({
    required this.name,
    required this.ipAddress,
    required this.httpPort,
    this.discoveryPort = 9090,
  });
  
  @override
  String toString() {
    return "$name ($ipAddress:$httpPort)";
  }
}

class PcCommunicationService {
  final Dio _dio = Dio();
  DrillTrackServer? _currentServer;
  
  // 单例模式
  static final PcCommunicationService _instance = PcCommunicationService._internal();
  
  factory PcCommunicationService() {
    return _instance;
  }
  
  PcCommunicationService._internal();
  
  // 设置PC服务器
  void setServer(Map<String, dynamic> serverData) {
    // 获取服务器名称，确保中文能正确显示
    final String serverName = serverData['name'] != null && serverData['name'].toString().trim().isNotEmpty
        ? serverData['name'].toString()
        : '钻孔轨迹仪数据处理系统';
    
    final String ipAddress = serverData['ip'];
    final int httpPort = serverData['http_port'] ?? 8080;
    final int discoveryPort = serverData['discovery_port'] ?? 9090;
    
    _currentServer = DrillTrackServer(
      name: serverName,
      ipAddress: ipAddress,
      httpPort: httpPort,
      discoveryPort: discoveryPort,
    );
    
    debugPrint('设置钻孔轨迹仪数据处理系统服务器: ${_currentServer.toString()}');
  }
  
  // 获取当前服务器
  DrillTrackServer? get currentServer => _currentServer;
  
  // 检查是否已连接到服务器
  bool get isConnected => _currentServer != null;
  
  // 测试服务器连接
  Future<bool> testConnection() async {
    if (_currentServer == null) {
      debugPrint('未设置服务器，无法测试连接');
      return false;
    }
    
    final String baseUrl = 'http://${_currentServer!.ipAddress}:${_currentServer!.httpPort}';
    final String apiUrl = '$baseUrl/api/status';
    debugPrint('正在测试服务器连接: $apiUrl');
   
    try {
      final Map<String, dynamic> testData = {
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "deviceId": "DrillTrack-Mobile-Test",
        "dataType": "DrillData",
        "values": [
          {"key": "test", "value": "connection"}
        ]
      };
      
      final response = await _dio.get(
        apiUrl,
        // data: jsonEncode(testData),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: 5000,
          sendTimeout: 5000,
        )
      );
      
      debugPrint('测试连接响应: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('测试连接失败: $e');
      return false;
    }
  }
  
  // 将RepoModel转换为DrillTrack API格式
  Map<String, dynamic> _convertRepoToApiFormat(RepoModel repo) {
    return {
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "deviceId": "DrillTrack-Mobile-${repo.id}",
      "dataType": "DrillData",
      "values": [
        {"key": "id", "value": repo.id},
        {"key": "name", "value": repo.name},
        {"key": "time", "value": repo.mnTime},
        {"key": "len", "value": repo.len},
        {"key": "mine", "value": repo.mine},
        {"key": "work", "value": repo.work},
        {"key": "factory", "value": repo.factory},
        {"key": "drilling", "value": repo.drilling}
      ]
    };
  }
  
  // 向PC同步数据
  Future<bool> syncDataToPC(RepoModel repo) async {
    if (_currentServer == null) {
      debugPrint('未设置服务器，无法同步');
      return false;
    }
    
    final String baseUrl = 'http://${_currentServer!.ipAddress}:${_currentServer!.httpPort}';
    final String apiUrl = '$baseUrl/api/data';
    
    try {
      // 转换数据为DrillTrack API格式
      final Map<String, dynamic> data = _convertRepoToApiFormat(repo);
      
      debugPrint('发送数据到服务器: $apiUrl');
      debugPrint('数据: ${jsonEncode(data)}');
      
      final response = await _dio.post(
        apiUrl,
        data: jsonEncode(data),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: 10000,
          sendTimeout: 10000,
        )
      );
      
      debugPrint('服务器响应: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('同步数据到服务器失败: $e');
      return false;
    }
  }
  
  // 批量同步数据
  Future<Map<int, bool>> batchSyncData(List<RepoModel> repos) async {
    Map<int, bool> results = {};
    
    for (var repo in repos) {
      if (repo.id != null) {
        bool success = await syncDataToPC(repo);
        results[repo.id!] = success;
      }
    }
    
    return results;
  }
  
  // 获取PC上的同步状态
  Future<List<Map<String, dynamic>>> getSyncStatus() async {
    if (_currentServer == null) {
      debugPrint('未设置服务器，无法获取同步状态');
      return [];
    }
    
    final String baseUrl = 'http://${_currentServer!.ipAddress}:${_currentServer!.httpPort}';
    
    try {
      final response = await _dio.get(
        '$baseUrl/api/data/status',
        options: Options(
          receiveTimeout: 5000,
          sendTimeout: 5000,
        )
      );
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map) {
          // 处理可能的不同响应格式
          final Map<String, dynamic> data = response.data;
          if (data.containsKey('syncedItems')) {
            return List<Map<String, dynamic>>.from(data['syncedItems']);
          }
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('获取同步状态失败: $e');
      return [];
    }
  }
} 