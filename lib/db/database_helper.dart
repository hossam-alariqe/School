


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ignore: unused_import
import '../models/grade_model.dart';
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
      // onUpgrade: _onUpgrade,
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
        // is_present INTEGER NOT NULL,

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

// أضف هذا الجدول في دالة _onCreate
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
  
await db.execute('''
  CREATE TABLE IF NOT EXISTS Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    email TEXT
  )
''');

  }
Future<void> _insertInitialData(Database db) async {
  // التحقق من عدم وجود بيانات مسبقًا
  final count = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM Users')
  );

  if (count == 0) {
    await db.insert('Users', {
      'username': 'admin',
      'password': 'admin123',
      'email': 'admin@school.com'
    });
  }
}









  // الدوال الجديدة لإدارة الفصول
  Future<int> insertClass(Map<String, dynamic> row) async {
    final db = await this.db;
    return await db.insert('Classes', row);
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final db = await this.db;
    return await db.query('Classes');
  }







      
    
  




  // إضافة بيانات الحضور
Future<int?> insertAttendance(Map<String, dynamic> data) async {
  final dbs = await db;
  return await dbs.insert('attendance', data,
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<Map<String, dynamic>>?> getStudents() async {
  final dbs = await db;
  return await dbs.query('students'); // افترض أن اسم جدول الطلاب هو students
}



Future<void> saveAttendance(List<Student> students, DateTime date, int classId) async {
  final db = await DatabaseHelperr().db;

  // تحويل التاريخ إلى تنسيق نصي (yyyy-MM-dd)
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);

  // استخدام Batch لإدخال البيانات بشكل جماعي
  final batch = db.batch();

  for (var student in students) {
    batch.insert(
      'Attendance',
      {
        'student_id': student.id,
        'date': formattedDate,
        'is_present': student.isPresent ? 1 : 0, // 1 لحاضر، 0 لغائب
        'class_id': classId, // إضافة class_id
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // استبدال البيانات إذا كانت موجودة
    );
  }

  // تنفيذ العمليات بشكل جماعي
  await batch.commit();

  ScaffoldMessenger.of(context as BuildContext).showSnackBar(
    const SnackBar(
      content: Text('تم حفظ الحضور بنجاح!'),
      backgroundColor: Colors.green,
    ),
  );
}



  Future<Map<int, bool>> getAttendanceForDate(String date) async {
    final dbs = await db;
    final result = await dbs.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );

    return {
      for (var row in result) row['student_id'] as int: (row['is_present'] as int) == 1,
    };
  }









}
