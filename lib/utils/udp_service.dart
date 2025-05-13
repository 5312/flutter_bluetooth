import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UdpService
{
    static const int SERVER_PORT = 9091; // PC端UDP广播端口
    static const int CLIENT_PORT = 9090; // 客户端使用动态端口
    static const String BROADCAST_IP = '255.255.255.255'; // 广播地址

    RawDatagramSocket? _broadcastSocket;
    RawDatagramSocket? _listenSocket;
    StreamController<Map<String, dynamic>> _deviceStreamController = StreamController<Map<String, dynamic>>.broadcast();
    Timer? _discoveryTimer;
    int _discoveryAttempts = 0;
    static const int MAX_DISCOVERY_ATTEMPTS = 5;
    bool _isDisposed = false; // 添加标志，标记服务是否已被销毁

    // 获取设备流，用于监听发现的设备
    Stream<Map<String, dynamic>> get deviceStream => _deviceStreamController.stream;

    // 单例模式
    static final UdpService _instance = UdpService._internal();

    factory UdpService()
    {
        return _instance;
    }

    UdpService._internal();

    // 初始化UDP服务
    Future<void> init() async
    {
        try
        {
            if (_isDisposed) {
                // 如果已销毁，重新创建 StreamController
                _deviceStreamController = StreamController<Map<String, dynamic>>.broadcast();
                _isDisposed = false;
            }
            
            // 关闭可能存在的旧套接字
            _broadcastSocket?.close();
            _listenSocket?.close();

            // 创建监听套接字 - 使用与服务器相同的端口进行监听
            _listenSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SERVER_PORT);
            int listenPort = _listenSocket!.port;
            debugPrint('UDP监听套接字绑定到端口: $listenPort');

            // 创建广播套接字 - 使用任意可用端口
            _broadcastSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, CLIENT_PORT);
            _broadcastSocket!.broadcastEnabled = true;
            int broadcastPort = _broadcastSocket!.port;
            debugPrint('UDP广播套接字绑定到端口: $broadcastPort');

            // 监听接收到的数据
            _listenSocket!.listen((RawSocketEvent event)
                {
                    if (!_isDisposed && event == RawSocketEvent.read) 
                    {
                        Datagram? datagram = _listenSocket!.receive();
                        if (datagram != null) 
                        {
                            try
                            {
                                // 使用utf8解码确保正确处理中文字符
                                String message = utf8.decode(datagram.data, allowMalformed: true);

                                // 跳过来自自己的消息
                                if (datagram.address.address == _getLocalAddress()) 
                                {
                                    debugPrint('忽略来自本机的消息');
                                    return;
                                }
                                
                                Map<String, dynamic> data;
                                try
                                {
                                    data = jsonDecode(message);
                                    debugPrint('收到UDP消息 [${datagram.address.address}:${datagram.port}]: $message');

                                    // 忽略自己发送的消息 - 增强检测逻辑
                                    if (data['type'] == 'client_discovery' || data['type'] == 'discovery') 
                                    {
                                        return;
                                    }

                                    // 检查是否是服务器通告或响应
                                    if (data['type'] == 'server_announce') 
                                    {
                                        // 确保IP地址信息存在
                                        if (!data.containsKey('ip')) 
                                        {
                                            data['ip'] = datagram.address.address;
                                        }

                                        // 确保包含HTTP端口
                                        if (!data.containsKey('http_port')) 
                                        {
                                            data['http_port'] = 8080; // 默认HTTP端口
                                        }

                                        debugPrint('发现钻孔轨迹仪数据处理系统服务器: ${datagram.address.address}:${data['http_port']}');
                                        // 检查 StreamController 状态再添加数据
                                        if (!_isDisposed && !_deviceStreamController.isClosed) {
                                            _deviceStreamController.add(data);
                                        }

                                        // 停止继续发现
                                        _stopDiscovery();
                                    }
                                    else 
                                    {
                                        debugPrint('收到未知类型的消息: ${data['type'] ?? '无类型'}，内容: $data');
                                        // 对于任何来自非本机的UDP消息，都假设它可能是服务器
                                        // 这是一个后备方案，当无法明确识别响应格式时
                                        Map<String, dynamic> serverInfo = 
                                        {
                                            'type': 'server_response',
                                            'name': 'Unknown Server',
                                            'ip': datagram.address.address,
                                            'http_port': 8080 // 假设默认HTTP端口
                                        };
                                        // 检查 StreamController 状态再添加数据
                                        if (!_isDisposed && !_deviceStreamController.isClosed) {
                                            _deviceStreamController.add(serverInfo);
                                        }
                                        _stopDiscovery();
                                    }
                                }
                                catch (e)
                                {
                                    debugPrint('解析UDP数据错误: $e');
                                }
                            }
                            catch (e)
                            {
                                debugPrint('处理UDP数据错误: $e');
                            }
                        }
                    }
                }
            );

            debugPrint('UDP服务初始化成功，监听端口: $listenPort, 广播端口: $broadcastPort');
        }
        catch (e)
        {
            debugPrint('UDP服务初始化失败: $e');
        }
    }

    // 获取本地IP地址
    String _getLocalAddress() 
    {
        try
        {
            return InternetAddress.anyIPv4.address;
        }
        catch (e)
        {
            return '127.0.0.1';
        }
    }

    // 发送广播消息，寻找PC端
    void discoverPcDevices() 
    {
        _stopDiscovery(); // 停止可能存在的之前的发现过程
        _discoveryAttempts = 0;
        _sendDiscoveryBroadcast();
    }

    // 发送单个发现广播
    void _sendDiscoveryBroadcast() 
    {
        if (_broadcastSocket == null) 
        {
            debugPrint('UDP socket未初始化');
            return;
        }

        if (_discoveryAttempts >= MAX_DISCOVERY_ATTEMPTS) 
        {
            debugPrint('达到最大尝试次数，停止发现');
            return;
        }

        _discoveryAttempts++;

        try
        {
            // 尝试多种格式的消息，以兼容不同的服务器实现
            // 格式1：按照DrillTrack规范
            Map<String, dynamic> data1 = 
            {
                'type': 'client_discovery',
                'client_id': '钻孔轨迹仪',
                'timestamp': DateTime.now().millisecondsSinceEpoch
            };

            // 发送所有格式的消息
            List<int> dataToSend1 = utf8.encode(jsonEncode(data1));
            _broadcastSocket!.send(dataToSend1, InternetAddress(BROADCAST_IP), SERVER_PORT);
            debugPrint('发送UDP广播1: ${jsonEncode(data1)}');

            // 2秒后再次尝试
            _discoveryTimer = Timer(const Duration(seconds: 2), _sendDiscoveryBroadcast);
        }
        catch (e)
        {
            debugPrint('发送UDP广播失败: $e');
        }
    }

    // 停止发现过程
    void _stopDiscovery() 
    {
        _discoveryTimer?.cancel();
        _discoveryTimer = null;
    }

    // 提供给外部调用的停止发现方法
    void stopDiscoveryAll() 
    {
        _stopDiscovery();
        _broadcastSocket?.close();
        _listenSocket?.close();
        
        // 不在这里关闭 StreamController，只关闭套接字
        // _deviceStreamController.close();
        debugPrint('UDP服务已停止发现');
    }

    // 关闭UDP服务
    void dispose() 
    {
        if (_isDisposed) {
            return; // 避免重复销毁
        }
        
        _stopDiscovery();
        _broadcastSocket?.close();
        _listenSocket?.close();
        
        if (!_deviceStreamController.isClosed) {
            _deviceStreamController.close();
        }
        
        _isDisposed = true;
        debugPrint('UDP服务已关闭');
    }
} 
