
import 'dart:typed_data';

String bytesToHex(bytes) {
  final buffer = StringBuffer();
  for (int byte in bytes) {
    // 每个字节转换为两位十六进制字符串
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
List<String> bytesToHexArray(bytes) {
  final hexArray = <String>[];
  for (int byte in bytes) {
    // 每个字节转换为两位十六进制字符串，并添加到数组中
    hexArray.add(byte.toRadixString(16).padLeft(2, '0'));
  }
  return hexArray;
}
