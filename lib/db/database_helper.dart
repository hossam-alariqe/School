


// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student_data.dart';

class DatabaseHelperr {
  static final DatabaseHelperr _instance = DatabaseHelperr._internal();
  factory DatabaseHelperr() => _instance;
  DatabaseHelperr._internal();

  static Database? _db;
  static const String _dbName = 'mange1.db';
  static const int _dbVersion = 6;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        place TEXT NOT NULL,
        gender TEXT NOT NULL,
        dob TEXT NOT NULL,
        age INTEGER NOT NULL,
        profilePic BLOB,
        class_id INTEGER,
        FOREIGN KEY(class_id) REFERENCES Classes(id)
      )
    ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS Attendance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      is_present INTEGER NOT NULL,
      class_id INTEGER,  
      FOREIGN KEY(student_id) REFERENCES Students(id),
      FOREIGN KEY(class_id) REFERENCES Classes(id)
    )
  ''');

await db.execute('''
  CREATE TABLE Grades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    class_id INTEGER NOT NULL,
    attendance REAL DEFAULT 0,
    quizzes REAL DEFAULT 0,
    assignments REAL DEFAULT 0,
    exams REAL DEFAULT 0,
    FOREIGN KEY(student_id) REFERENCES Students(id),
    FOREIGN KEY(class_id) REFERENCES Classes(id)
  )
''');
  
  }

}
