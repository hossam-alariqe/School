import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_mod.dart';
import '../models/student_data.dart';
import '../providers/class_provaider.dart';
import '../providers/student_provider.dart';
import '../services/student_service.dart';
import 'add_grades_screean.dart';

class GradesReportScreen extends StatelessWidget {
  const GradesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير الدرجات',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => Provider.of<StudentProvider>(context, listen: false)
                .loadStudentsByClass(null),
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
              _buildClassFilter(context),
              const SizedBox(height: 20),
              Expanded(child: _buildGradesTable(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassFilter(BuildContext context) {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.filter_list, color: Colors.blueGrey),
                hintText: 'اختر الفصل',
              ),
              style: const TextStyle(color: Colors.blueGrey),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('جميع الفصول'),
                ),
                ...classProvider.classes.map((cls) {
                  return DropdownMenuItem<int>(
                    value: cls.id,
                    child: Text(cls.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                }),
              ],
              onChanged: (value) {
                Provider.of<StudentProvider>(context, listen: false)
                    .loadStudentsByClass(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradesTable(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchGrades(context, provider.students),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey[800],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 60, color: Colors.blueGrey[300]),
                    const SizedBox(height: 10),
                    Text('لا يوجد بيانات متاحة',
                        style: TextStyle(
                            color: Colors.blueGrey[500],
                            fontSize: 16)),
                  ],
                ),
              );
            }

            final grades = snapshot.data!;
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 25,
                    dataRowHeight: 50,
                    headingTextStyle: TextStyle(
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text('الطالب')),
                      DataColumn(label: Text('الفصل')),
                      DataColumn(label: Text('الحضور'), numeric: true),
                      DataColumn(label: Text('الكويزات'), numeric: true),
                      DataColumn(label: Text('التكاليف'), numeric: true),
                      DataColumn(label: Text('الاختبار'), numeric: true),
                      DataColumn(label: Text('المجموع'), numeric: true),
                      DataColumn(label: Text(' ')),
                    ],
                    rows: grades.map((grade) {
                      final total = (grade['attendance'] ?? 0) +
                          (grade['quizzes'] ?? 0) +
                          (grade['assignments'] ?? 0) +
                          (grade['exams'] ?? 0);

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            return grades.indexOf(grade) % 2 == 0
                                ? Colors.blueGrey[50]
                                : null;
                          },
                        ),
                        cells: [
                          DataCell(Text(grade['student_name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(grade['class_name'] ?? '')),
                          DataCell(_buildGradeCell(grade['attendance'])),
                          DataCell(_buildGradeCell(grade['quizzes'])),
                          DataCell(_buildGradeCell(grade['assignments'])),
                          DataCell(_buildGradeCell(grade['exams'])),
                          DataCell(Text(total.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit_note,
                                  color: Colors.blueGrey),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddGradesScreen(
                                    initialClassId: grade['class_id'],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGradeCell(dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        (value ?? 0).toStringAsFixed(1),
        style: TextStyle(
          color: Colors.blueGrey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchGrades(
      BuildContext context, List<Student> students) async {
    List<Map<String, dynamic>> grades = [];
    final classProvider = Provider.of<ClassProvider>(context, listen: false);

    for (var student in students) {
      final grade = await StudentService.getStudentGrades(student.id!);
      final className = classProvider.classes
          .firstWhere(
            (c) => c.id == student.classId,
            orElse: () => SchoolClass(name: 'غير محدد'),
          )
          .name;

      grades.add({
        'student_id': student.id,
        'student_name': student.name,
        'class_id': student.classId,
        'class_name': className,
        ...grade,
      });
    }
    return grades;
  }
}