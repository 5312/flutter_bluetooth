import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
    String path = join(await getDatabasesPath(), 'app_data_list_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE repos(id INTEGER PRIMARY KEY, name TEXT, mnTime TEXT)",
        );
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

  Future<void> updateDataList(DataListModel dataList) async {
    final db = await database;
    await db.update(
      'data',
      dataList.toJson(),
      where: "id = ?",
      whereArgs: [dataList.id],
    );
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
  Future<void> insertRepo(RepoModel repo) async {
    final db = await database;
    await db.insert(
      'repos',
      repo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('inter success');
  }

  Future<List<RepoModel>> getRepos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('repos');

    return List.generate(maps.length, (i) {
      return RepoModel.fromJson(maps[i]);
    });
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

  Future<void> deleteRepo(int id) async {
    final db = await database;
    await db.delete(
      'repos',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
