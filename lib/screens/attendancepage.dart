import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/class_mod.dart';
import '../models/student_data.dart';
import '../providers/class_provaider.dart';
import '../db/database_helper.dart';

class AdvancedAttendanceReport extends StatelessWidget {
  const AdvancedAttendanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الحضور المتقدم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showDateFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<ClassProvider>(
        builder: (context, classProvider, _) {
          return FutureBuilder<List<ClassAttendanceReport>>(
            future: _fetchAttendanceData(classProvider.classes),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return _buildReportList(snapshot.data!);
            },
          );
        },
      ),
    );
  }

  Future<List<ClassAttendanceReport>> _fetchAttendanceData(List<SchoolClass> classes) async {
    final db = await DatabaseHelperr().db;
    final reports = <ClassAttendanceReport>[];

    for (final cls in classes) {
      final students = await db!.query(
        'Students',
        where: 'class_id = ?',
        whereArgs: [cls.id],
      );

      final attendanceData = <String, List<StudentAttendance>>{};
      
      for (final student in students) {
        final attendanceRecords = await db.query(
          'Attendance',
          where: 'student_id = ?',
          whereArgs: [student['id']],
        );

        for (final record in attendanceRecords) {
          final date = record['date'] as String;
          attendanceData.putIfAbsent(date, () => []).add(
            StudentAttendance(
              student: Student.fromMap(student),
              isPresent: record['is_present'] == 1,
            ),
          );
        }
      }

      reports.add(ClassAttendanceReport(
        classInfo: cls,
        dates: attendanceData.keys.toList(),
        attendanceRecords: attendanceData,
      ));
    }

    return reports;
  }

  Widget _buildReportList(List<ClassAttendanceReport> reports) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildClassSection(report);
      },
    );
  }

  Widget _buildClassSection(ClassAttendanceReport report) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.class_, color: Colors.blue),
        title: Text(
          report.classInfo.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تفاصيل الحضور',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...report.dates.map((date) => _buildDateSection(date, report)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date, ClassAttendanceReport report) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_today, size: 20),
        title: Text(
          DateFormat('yyyy-MM-dd').format(DateTime.parse(date)),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('اسم الطالب')),
              DataColumn(label: Text('الحالة')),
              DataColumn(label: Text('النسبة')),
            ],
            rows: report.attendanceRecords[date]!.map((record) {
              final totalDays = report.dates.length;
              final presentDays = report.attendanceRecords[date]!
                  .where((r) => r.isPresent)
                  .length;

              return DataRow(
                cells: [
                  DataCell(Text(record.student.name!)),
                  DataCell(
                    record.isPresent
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  ),
                  DataCell(Text('${(presentDays / totalDays * 100).toStringAsFixed(1)}%')),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية حسب التاريخ'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              // يمكن إضافة عناصر تحكم للتصفية هنا
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class ClassAttendanceReport {
  final SchoolClass classInfo;
  final List<String> dates;
  final Map<String, List<StudentAttendance>> attendanceRecords;

  ClassAttendanceReport({
    required this.classInfo,
    required this.dates,
    required this.attendanceRecords,
  });
}

class StudentAttendance {
  final Student student;
  final bool isPresent;

  StudentAttendance({
    required this.student,
    required this.isPresent,
  });
}