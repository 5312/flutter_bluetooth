import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bluetooth_mini/models/employee_model.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/models/time_model.dart';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE employees(id INTEGER PRIMARY KEY, inclination REAL, azimuth REAL, repoId INTEGER)",
        );
        await db.execute(
          "CREATE TABLE repos(id INTEGER PRIMARY KEY, name TEXT, mnTime TEXT)",
        );
      },
    );
  }

  Future<void> insertEmployees(List<Employee> employees) async {
    final db = await database;
    final batch = db.batch();

    for (var employee in employees) {
      batch.insert(
        'employees',
        employee.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
  //  保存定时同步数据
  Future<void> insertTime(List<TimeModel> employees) async {
    final db = await database;
    final batch = db.batch();

    for (var employee in employees) {
      batch.insert(
        'time',
        employee.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }


  Future<void> insertRepo(RepoModel repo) async {
    final db = await database;
    await db.insert(
      'repos',
      repo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('inter success');
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');

    return List.generate(maps.length, (i) {
      return Employee.fromJson(maps[i]);
    });
  }

  Future<List<RepoModel>> getRepos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('repos');

    return List.generate(maps.length, (i) {
      return RepoModel.fromJson(maps[i]);
    });
  }

  Future<void> updateEmployee(Employee employee) async {
    final db = await database;
    await db.update(
      'employees',
      employee.toJson(),
      where: "id = ?",
      whereArgs: [employee.id],
    );
  }

  Future<void> updateRepo(RepoModel repo) async {
    final db = await database;
    await db.update(
      'repos',
      repo.toJson(),
      where: "id = ?",
      whereArgs: [repo.id],
    );
  }

  Future<void> deleteEmployee(int id) async {
    final db = await database;
    await db.delete(
      'employees',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteRepo(int id) async {
    final db = await database;
    await db.delete(
      'repos',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
