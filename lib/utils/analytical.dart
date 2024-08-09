import './hex.dart';

class Analytical {
  final List<int> value;

  Analytical(this.value);
  // 补零
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
// 格式化时间
  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(secs)}';
  }

  // 获取时间
  String dataTime() {
    // 计算时间
    int seconds = value[7];
    int minutes = value[6] * 255;
    int hours = value[5] * minutes;
    int formattedTime = hours + minutes + seconds;
    String time = formatTime(formattedTime);
    return time;
  }

  // 解析数据
/*   List<String> analyticalData() {
    List<String> hexStringList = bytesToHexArray(value);
    // 取值 path,roll,heading
    List<String> angle = getAngle(hexStringList);
    return angle;
  } */

  List<String> getAngle() {
    String pitch = getPitch();
    String roll = getRoll();
    String heading = getHeading();
    return [pitch, roll, heading];
  }

  String getPitch() {
    List<String> hexStringList = bytesToHexArray(value);
    String pitch =
        readAngle(hexStringList[8], hexStringList[9], hexStringList[10]);
    return pitch;
  }

  String getRoll() {
    List<String> hexStringList = bytesToHexArray(value);
    String roll =
        readAngle(hexStringList[11], hexStringList[12], hexStringList[13]);
    return roll;
  }

  String getHeading() {
    List<String> hexStringList = bytesToHexArray(value);
    String heading =
        readAngle(hexStringList[14], hexStringList[15], hexStringList[16]);
    return heading;
  }

  // 【3】-fo-对应和 HCM600 命令字 0x84
  // 【5】【6】【7】之和为第几条数据
  // 【8】【9】【10】picth仰角
  // 【11】【12】【13】roll倾斜角
  // 【14】【15】【16】heading 方位角
  //读取 roll ,path,heading
  String readAngle(String roll1, String roll2, String roll3) {
    // 从第一个元素中取出第一个字符
    String firstChar = roll1[0];
    String data = '';
    if (firstChar == '0') {
      data += '+';
    } else {
      data += '-';
    }
    // 使用字符串插值来拼接结果
    data += '${roll1[1]}$roll2.$roll3';
    return data;
  }
}
