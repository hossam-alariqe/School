import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import '../db/database_helper.dart';
import '../models/class_mod.dart';
import '../models/student_data.dart';
import '../providers/class_provaider.dart';
import '../providers/student_provider.dart';
// ignore: unused_import
import '../utils/helper_functions.dart';
// ignore: unused_import
import '../widgets/student_delete_undo_sheet.dart';
import 'view_students_details_screen.dart';

class ClassBasedStudentsScreen extends StatefulWidget {
  ClassBasedStudentsScreen(int? id);

  @override
  _ClassBasedStudentsScreenState createState() =>
      _ClassBasedStudentsScreenState();
}

class _ClassBasedStudentsScreenState extends State<ClassBasedStudentsScreen> {
  int? _selectedClassId;
  bool _isLoading = true;
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Provider.of<ClassProvider>(context, listen: false).loadClasses();
    await Provider.of<StudentProvider>(context, listen: false).loadStudents();
    setState(() => _isLoading = false);
  }

  Future<void> _filterStudents(int? classId) async {
    setState(() {
      _selectedClassId = classId;
      _isLoading = true;
    });

    final students = await Provider.of<StudentProvider>(context, listen: false)
        .getStudentsByClass(classId);

    setState(() {
      _filteredStudents = students;
      _isLoading = false;
    });
  }

  Future<void> _handleDeleteStudent(Student student) async {
    final scaffold = ScaffoldMessenger.of(context);
    final provider = Provider.of<StudentProvider>(context, listen: false);
    
    // حفظ نسخة للتراجع
    final deletedStudent = student;
    final deletedIndex = _filteredStudents.indexOf(student);

    // حذف مؤقت من القائمة
    setState(() => _filteredStudents.removeAt(deletedIndex));

    // عرض إمكانية التراجع
    scaffold.showSnackBar(
      SnackBar(
        content: Text('تم حذف ${student.name}'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() => _filteredStudents.insert(deletedIndex, deletedStudent));
            provider.addStudent(deletedStudent);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    // الحذف النهائي من قاعدة البيانات بعد التأكيد
    await provider.deleteStudent(student.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض الطلاب حسب الفصل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildClassFilterDropdown(),
          Expanded(
            child: _isLoading
                ?const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? _buildEmptyState()
                    : _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassFilterDropdown() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButton<int>(
                value: _selectedClassId,
                isExpanded: true,
                underline: const SizedBox(),
                hint:const  Text('اختر فصل لعرض طلابه'),
                items: [
                const   DropdownMenuItem<int>(
                    value: null,
                    child: Text('جميع الطلاب'),
                  ),
                  ...classProvider.classes.map((cls) {
                    return DropdownMenuItem<int>(
                      value: cls.id,
                      child: Text(cls.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) => _filterStudents(value),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return Dismissible(
          key: Key(student.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد الحذف'),
                content: Text('هل أنت متأكد من حذف ${student.name}؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child:const  Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child:const  Text('حذف', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) => _handleDeleteStudent(student),
          child: _buildStudentCard(student),
        );
      },
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin:const  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: ListTile(
        contentPadding:const  EdgeInsets.all(12),
        leading: _buildStudentAvatar(student),
        title: Text(
          student.name ?? '',
          style:const  TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.place ?? ''),
            FutureBuilder<String>(
              future: _getClassName(student.classId),
              builder: (context, snapshot) {
                return Text(
                  'الفصل: ${snapshot.data ?? 'غير محدد'}',
                  style: TextStyle(color: Colors.grey[600]),
                );
              },
            ),
          ],
        ),
        trailing:const  Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => _navigateToStudentDetails(student),
      ),
    );
  }

  Widget _buildStudentAvatar(Student student) {
    return Hero(
      tag: 'student-avatar-${student.id}',
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        backgroundImage: student.profilePic != null
            ? MemoryImage(student.profilePic!)
            : null,
        child: student.profilePic == null
            ? Icon(Icons.person, size: 30, color: Colors.grey[600])
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.group_off, size: 100, color: Colors.grey[400]),
      const   SizedBox(height: 20),
        Text(
          'لا يوجد طلاب في هذا الفصل',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
       const  SizedBox(height: 10),
        Text(
          _selectedClassId == null
              ? 'اختر فصل من القائمة أعلاه'
              : 'اضغط زر (+) لإضافة طلاب جدد',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Future<String> _getClassName(int? classId) async {
    if (classId == null) return 'غير محدد';
    final classes = Provider.of<ClassProvider>(context, listen: false).classes;
    return classes.firstWhere((c) => c.id == classId, orElse: () => SchoolClass(name: '')).name;
  }

  void _navigateToStudentDetails(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewStudentsDetailsScreen(studentDetail: student),
      ),
    ).then((_) => _filterStudents(_selectedClassId));
  }
}