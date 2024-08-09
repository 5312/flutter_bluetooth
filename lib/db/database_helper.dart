import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bluetooth_mini/models/employee_model.dart';
import 'package:bluetooth_mini/models/repo_model.dart';

import 'package:bluetooth_mini/models/data_list_model.dart';

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
    String path = join(await getDatabasesPath(), 'app_data_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // await db.execute(
        //   "CREATE TABLE employees(id INTEGER PRIMARY KEY, inclination REAL, azimuth REAL, repoId INTEGER)",
        // );
        // await db.execute(
        //   "CREATE TABLE repos(id INTEGER PRIMARY KEY, name TEXT, mnTime TEXT)",
        // );
        await db.execute(
          "CREATE TABLE data(id INTEGER PRIMARY KEY, time TEXT, pitch REAL, roll REAL, heading REAL, repoId INTEGER, designPitch REAL, designRoll REAL)",
        );
      },
    );
  }

// 插入DataListModel
  Future<void> insertDataList(DataListModel dataList) async {
    final db = await database;
    final batch = db.batch();

    batch.insert(
      'data',
      dataList.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await batch.commit(noResult: true);
  }

// 查询数据
  Future<List<DataListModel>> getDataList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('data');
    return List.generate(maps.length, (i) {
      return DataListModel.fromJson(maps[i]);
    });
  }

  Future<void> deleteDataList(int id) async {
    // Get a reference to the database.
    final db = await database;
    // Remove the Dog from the database.
    await db.delete(
      'data',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

// -----------------
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

  Future<void> deleteEmployee(int id) async {
    final db = await database;
    await db.delete(
      'employees',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
