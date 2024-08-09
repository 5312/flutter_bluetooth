import 'utils.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final Map<DeviceIdentifier, StreamControllerReemit<bool>> _cglobal = {};
final Map<DeviceIdentifier, StreamControllerReemit<bool>> _dglobal = {};

//拓展设备方法
/// connect & disconnect + update stream
extension Extra on BluetoothDevice {
  // convenience
  StreamControllerReemit<bool> get _cstream {
    _cglobal[remoteId] ??= StreamControllerReemit(initialValue: false);
    return _cglobal[remoteId]!;
  }

  // convenience
  StreamControllerReemit<bool> get _dstream {
    _dglobal[remoteId] ??= StreamControllerReemit(initialValue: false);
    return _dglobal[remoteId]!;
  }

  // get stream
  Stream<bool> get isConnecting {
    return _cstream.stream;
  }

  // get stream
  Stream<bool> get isDisconnecting {
    return _dstream.stream;
  }

  // 连接
  // connect & update stream
  Future<void> connectAndUpdateStream() async {
    _cstream.add(true);
    try {
      await connect(mtu: null);
    } catch (e) {
      _cstream.add(false);
      rethrow;
    }
  }

  // 断开
  // disconnect & update stream
  Future<void> disconnectAndUpdateStream({bool queue = true}) async {
    _dstream.add(true);

    try {
      await disconnect(queue: queue);
    } finally {
      _dstream.add(false);
    }
  }
}
