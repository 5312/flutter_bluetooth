import 'dart:convert';

class MyMine {
  final int id;
  final String name;

  MyMine(this.id, this.name);

  // 将 MyMine 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // 从 Map 创建 MyMine
  factory MyMine.fromMap(Map<String, dynamic> map) {
    return MyMine(
      map['id'],
      map['name'],
    );
  }

  // 将 MyMine 转换为 JSON 字符串
  String toJson() => json.encode(toMap());

  // 从 JSON 字符串创建 MyMine
  factory MyMine.fromJson(String source) => MyMine.fromMap(json.decode(source));
}

// 工作面
class MyWork {
  final int id;
  final int mineId;
  final String name;

  MyWork(this.id, this.mineId, this.name);

  // 将 MyMine 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mineId': mineId,
      'name': name,
    };
  }

  // 从 Map 创建 MyMine
  factory MyWork.fromMap(Map<String, dynamic> map) {
    return MyWork(
      map['id'],
      map['mineId'],
      map['name'],
    );
  }

  // 将 MyMine 转换为 JSON 字符串
  String toJson() => json.encode(toMap());

  // 从 JSON 字符串创建 MyMine
  factory MyWork.fromJson(String source) => MyWork.fromMap(json.decode(source));
}

// 钻厂
class MyFactory {
  final int id;
  final int workId;
  final String name;

  MyFactory(this.id, this.workId, this.name);

  // 将 MyMine 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workId': workId,
      'name': name,
    };
  }

  // 从 Map 创建 MyMine
  factory MyFactory.fromMap(Map<String, dynamic> map) {
    return MyFactory(
      map['id'],
      map['workId'],
      map['name'],
    );
  }

  // 将 MyMine 转换为 JSON 字符串
  String toJson() => json.encode(toMap());

  // 从 JSON 字符串创建 MyMine
  factory MyFactory.fromJson(String source) => MyFactory.fromMap(json.decode(source));
}

class MyDrilling {
  final int id;
  final int factoryId;
  final String name;

  MyDrilling(this.id, this.factoryId, this.name);

  // 将 MyMine 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'factoryId': factoryId,
      'name': name,
    };
  }

  // 从 Map 创建 MyMine
  factory MyDrilling.fromMap(Map<String, dynamic> map) {
    return MyDrilling(
      map['id'],
      map['factoryId'],
      map['name'],
    );
  }

  // 将 MyMine 转换为 JSON 字符串
  String toJson() => json.encode(toMap());

  // 从 JSON 字符串创建 MyMine
  factory MyDrilling.fromJson(String source) => MyDrilling.fromMap(json.decode(source));
}