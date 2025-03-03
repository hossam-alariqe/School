// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_data.dart';
import '../providers/class_provaider.dart';
import '../providers/student_provider.dart';
import '../services/student_service.dart';

class AddGradesScreen extends StatefulWidget {
  final int? initialClassId;
  const AddGradesScreen({super.key, this.initialClassId});

  @override
  _AddGradesScreenState createState() => _AddGradesScreenState();
}

class _AddGradesScreenState extends State<AddGradesScreen> {
  int? _selectedClassId;
  final Map<int, Map<String, double>> _grades = {};

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.initialClassId;
    if (_selectedClassId != null) _loadExistingGrades();
  }

  Future<void> _loadExistingGrades() async {
    final students = Provider.of<StudentProvider>(context, listen: false)
        .students
        .where((s) => s.classId == _selectedClassId)
        .toList();

    for (var student in students) {
      final grades = await StudentService.getStudentGrades(student.id!);
      if (grades.isNotEmpty) {
        _grades[student.id!] = {
          'attendance': grades['attendance'] ?? 0.0,
          'quizzes': grades['quizzes'] ?? 0.0,
          'assignments': grades['assignments'] ?? 0.0,
          'exams': grades['exams'] ?? 0.0,
        };
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدرجات',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveGrades,
            tooltip: 'حفظ التعديلات',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildClassFilter(),
              const SizedBox(height: 20),
              Expanded(
                child: _buildStudentsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassFilter() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<int>(
              value: _selectedClassId,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.class_, color: Colors.blueGrey),
              ),
              style: const TextStyle(color: Colors.blueGrey),
              items: [
                ...classProvider.classes.map((cls) {
                  return DropdownMenuItem<int>(
                    value: cls.id,
                    child: Text(cls.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                }),
              ],
              onChanged: (value) async {
                setState(() => _selectedClassId = value);
                await Provider.of<StudentProvider>(context, listen: false)
                    .loadStudentsByClass(value);
                _loadExistingGrades();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsList() {
    final students = Provider.of<StudentProvider>(context)
        .students
        .where((s) => s.classId == _selectedClassId)
        .toList();

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 60, color: Colors.blueGrey[300]),
            const SizedBox(height: 10),
            Text('لا يوجد طلاب في هذا الفصل',
                style: TextStyle(
                    color: Colors.blueGrey[500],
                    fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = students[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey[100],
                    foregroundImage: student.profilePic != null
                        ? MemoryImage(student.profilePic!)
                        : null,
                    child: student.profilePic == null
                        ? const Icon(Icons.person, color: Colors.blueGrey)
                        : null,
                  ),
                  title: Text(student.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(student.place ?? '',
                      style: TextStyle(color: Colors.blueGrey[400])),
                ),
                const Divider(height: 20),
                _buildGradeInputs(student.id!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeInputs(int studentId) {
    final currentGrades = _grades[studentId] ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGradeField('الحضور', studentId, 'attendance', 30,
              currentGrades['attendance']?.toString() ?? ''),
          _buildGradeField('الكويزات', studentId, 'quizzes', 20,
              currentGrades['quizzes']?.toString() ?? ''),
          _buildGradeField('التكاليف', studentId, 'assignments', 25,
              currentGrades['assignments']?.toString() ?? ''),
          _buildGradeField('الاختبار', studentId, 'exams', 25,
              currentGrades['exams']?.toString() ?? ''),
        ],
      ),
    );
  }

  Widget _buildGradeField(String label, int studentId, String type,
      double max, String initialValue) {
    final controller = TextEditingController(text: initialValue);

    return SizedBox(
      width: 70,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.blueGrey[600], fontSize: 12),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: Colors.blueGrey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintText: '0-${max.toInt()}',
          hintStyle: TextStyle(color: Colors.blueGrey[300]),
        ),
        style: TextStyle(
            color: Colors.blueGrey[800],
            fontWeight: FontWeight.w500),
        validator: (value) {
          final grade = double.tryParse(value ?? '') ?? 0.0;
          if (grade > max) return '!';
          return null;
        },
        onChanged: (value) {
          final grade = double.tryParse(value) ?? 0.0;
          _grades.update(
            studentId,
            (existing) => {...existing, type: grade},
            ifAbsent: () => {type: grade},
          );
        },
      ),
    );
  }

  Future<void> _saveGrades() async {
    if (_selectedClassId == null) return;

    for (var entry in _grades.entries) {
      final existing = await StudentService.getStudentGrades(entry.key);
      
      if (existing.isNotEmpty) {
        await StudentService.updateGrade(entry.key, {
          'attendance': entry.value['attendance'],
          'quizzes': entry.value['quizzes'],
          'assignments': entry.value['assignments'],
          'exams': entry.value['exams'],
        });
      } else {
        await StudentService.insertGrade({
          'student_id': entry.key,
          'class_id': _selectedClassId!,
          ...entry.value,
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ التعديلات بنجاح!'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}