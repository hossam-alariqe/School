// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
// ignore: unused_import
import '../models/student_data.dart';
import '../providers/class_provaider.dart';
import '../providers/student_provider.dart';
import '../db/database_helper.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime? _selectedDate;
  int? _selectedClassId;
  Map<int, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassProvider>(context, listen: false).loadClasses();
      Provider.of<StudentProvider>(context, listen: false).loadStudents();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _loadAttendanceForDate();
      });
    }
  }

  Future<void> _loadAttendanceForDate() async {
    if (_selectedClassId == null || _selectedDate == null) return;

    final db = await DatabaseHelperr().db;
    final students = Provider.of<StudentProvider>(context, listen: false)
        .students
        .where((s) => s.classId == _selectedClassId)
        .toList();

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    for (var student in students) {
      final result = await db!.query(
        'Attendance',
        where: 'student_id = ? AND date = ?',
        whereArgs: [student.id, formattedDate],
      );

      setState(() {
        _attendanceStatus[student.id!] = result.isNotEmpty 
            ? result.first['is_present'] == 1 
            : false;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedClassId == null || _selectedDate == null) return;

    final db = await DatabaseHelperr().db;
    final batch = db!.batch();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    _attendanceStatus.forEach((studentId, isPresent) {
      batch.insert(
        'Attendance',
        {
          'student_id': studentId,
          'date': formattedDate,
          'is_present': isPresent ? 1 : 0,
          'class_id': _selectedClassId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الحضور بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف الحضور والغياب'),
        actions: [
          IconButton(
            icon:const Icon(Icons.save),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateClassSelector(),
            const SizedBox(height: 20),
            Expanded(child: _buildAttendanceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateClassSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildClassDropdown(),
        ),
        SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassDropdown() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        return DropdownButtonFormField<int>(
          value: _selectedClassId,
          decoration: const InputDecoration(
            labelText: 'اختر الفصل',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('جميع الفصول', style: TextStyle(color: Colors.grey)),
            ),
            ...classProvider.classes.map((cls) {
              return DropdownMenuItem<int>(
                value: cls.id,
                child: Text(cls.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedClassId = value;
              _loadAttendanceForDate();
            });
          },
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    final students = Provider.of<StudentProvider>(context)
        .students
        .where((s) => s.classId == _selectedClassId)
        .toList();

    if (students.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد طلاب في هذا الفصل',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (context, index) =>const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = students[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: student.profilePic != null
                  ? MemoryImage(student.profilePic!)
                  : null,
              child: student.profilePic == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              student.name ?? 'بدون اسم',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(student.place ?? 'بدون منطقة'),
            trailing: Switch(
              value: _attendanceStatus[student.id] ?? false,
              activeColor: Colors.green,
              inactiveTrackColor: Colors.red[200],
              onChanged: (value) {
                setState(() {
                  _attendanceStatus[student.id!] = value;
                });
              },
            ),
          ),
        );
      },
    );
  }
}