import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/student_data.dart';

class StudentService {
  static final DatabaseHelperr _dbHelper = DatabaseHelperr();

  // إضافة طالب جديد مع دعم الصف الدراسي
  static Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await _dbHelper.db;
    return await db.rawInsert(
      '''
      INSERT INTO Students(
        name, 
        place, 
        gender, 
        dob, 
        age, 
        profilePic,
        class_id
      ) VALUES(?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        row['name'],
        row['place'],
        row['gender'],
        row['dob'],
        row['age'],
        row['profilePic'],
        row['class_id'], 
      ],
    );
  }

  // الحصول على جميع الطلاب مع دعم التصفية حسب الصف
  static Future<List<Student>> getAllStudents({int? classId}) async {
    final db = await _dbHelper.db;
    
    final where = classId != null ? 'class_id = ?' : null;
    final whereArgs = classId != null ? [classId] : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'Students',
      where: where,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // تحديث بيانات الطالب مع دعم الصف الدراسي
  static Future<int> editStudentDetails(Student student) async {
    final db = await _dbHelper.db;
    return await db.rawUpdate(
      '''
      UPDATE Students SET
        name = ?, 
        place = ?, 
        gender = ?, 
        dob = ?, 
        age = ?, 
        profilePic = ?,
        class_id = ?
      WHERE id = ?
      ''',
      [
        student.name,
        student.place,
        student.gender,
        student.dob,
        student.age,
        student.profilePic,
        student.classId,
        student.id
      ],
    );
  }

  // حذف طالب (بدون تغيير)
  static Future<int> deleteStudent(int id) async {
    final db = await _dbHelper.db;
    return await db.rawDelete(
      'DELETE FROM Students WHERE id = ?',
      [id],
    );
  }

//  للدرجات إضافة الدوال الجديدة

static Future<Map<String, dynamic>> getStudentGrades(int studentId) async {
  final db = await _dbHelper.db;
  final result = await db.query(
    'Grades',
    where: 'student_id = ?',
    whereArgs: [studentId],
  );
  return result.isNotEmpty ? result.first.cast<String, dynamic>() : {};
}

static Future<void> insertGrade(Map<String, dynamic> data) async {
  final db = await _dbHelper.db;
  await db.insert(
    'Grades',
    data,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

static Future<void> updateGrade(int studentId, Map<String, dynamic> data) async {
  final db = await _dbHelper.db;
  await db.update(
    'Grades',
    data,
    where: 'student_id = ?',
    whereArgs: [studentId],
  );
}

  
}