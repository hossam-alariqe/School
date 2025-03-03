import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/class_mod.dart';

class ClassProvider extends ChangeNotifier {
  List<SchoolClass> _classes = [];
  List<SchoolClass> get classes => _classes;

  get selectedClassId => null;

  Future<void> loadClasses() async {
    final db = await DatabaseHelperr().db;
    final List<Map<String, dynamic>> maps = await db.query('Classes');
    _classes = maps.map((e) => SchoolClass.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addClass(String className) async {
    final db = await DatabaseHelperr().db;
    await db.insert(
      'Classes',
      {'name': className},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadClasses();
  }

  Future<void> deleteClass(int id) async {
    final db = await DatabaseHelperr().db;
    await db.delete(
      'Classes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadClasses();
  }
}