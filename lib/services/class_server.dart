import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';

class ClassService {
  final DatabaseHelperr _dbHelper = DatabaseHelperr();

  // إضافة فصل جديد
  Future<int> insertClass(String className) async {
    final db = await _dbHelper.db;
    return await db.insert(
      'Classes',
      {'name': className},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على جميع الفصول
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    final db = await _dbHelper.db;
    return await db.query('Classes');
  }

  // تحديث بيانات الفصل
  Future<int> updateClass(int id, String newName) async {
    final db = await _dbHelper.db;
    return await db.update(
      'Classes',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // حذف فصل
  Future<int> deleteClass(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'Classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // البحث عن فصل بالاسم
  Future<List<Map<String, dynamic>>> searchClasses(String query) async {
    final db = await _dbHelper.db;
    return await db.query(
      'Classes',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }
}