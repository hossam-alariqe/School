// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/class_mod.dart';
import '../models/student_data.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStudents() async {
    try {
      _isLoading = true;
      notifyListeners();

      _students = await StudentService.getAllStudents();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'فشل في تحميل بيانات الطلاب: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StudentService.insertStudent(student.toMap());
      await loadStudents();
    } catch (e) {
      _errorMessage = 'فشل في إضافة الطالب: ${e.toString()}';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StudentService.editStudentDetails(student);
      await loadStudents();
    } catch (e) {
      _errorMessage = 'فشل في تحديث البيانات: ${e.toString()}';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await StudentService.deleteStudent(id);
      _students.removeWhere((student) => student.id == id);
    } catch (e) {
      _errorMessage = 'فشل في حذف الطالب: ${e.toString()}';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Student>> getStudentsByClass(int? classId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelperr().db;
      final where = classId != null ? 'class_id = ?' : null;
      final whereArgs = classId != null ? [classId] : null;

      final result = await db.query(
        'Students',
        where: where,
        whereArgs: whereArgs,
      );

      return result.map((e) => Student.fromMap(e)).toList();
    } catch (e) {
      _errorMessage = 'فشل في تصفية البيانات: ${e.toString()}';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ignore: non_constant_identifier_names
Future<void> loadStudentsByClass(int? classId) async {
  try {
    _isLoading = true;
    notifyListeners();

    _students = await StudentService.getAllStudents(classId: classId);
    _errorMessage = null;
  } catch (e) {
    _errorMessage = 'فشل في تحميل الطلاب: ${e.toString()}';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}