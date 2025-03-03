// ignore_for_file: unused_import

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import '../models/student_data.dart';
import '../providers/class_provaider.dart';
import '../services/student_service.dart';
import '../widgets/custom_date_and_age_picker.dart';
import '../widgets/image_upload.dart';

class AddStudentsScreen extends StatefulWidget {
  final Student? initialStudent;

  const AddStudentsScreen({super.key, this.initialStudent,isEdit});

  @override
  _AddStudentsScreenState createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  String? _selectedGender;
  String _selectedDob = '';
  int? _selectedAge;
  Uint8List? _imageBytes;
  int? _selectedClassId;
  Function? _clearImage;
  Uint8List? _initialImageBytes;
  bool? isEdit;

  @override
  void initState() {
    super.initState();

    _initializeForm();
    context.read<ClassProvider>().loadClasses();
  }

  void _initializeForm() {

       if (widget.initialStudent != null) {
      isEdit = true;
      // Pre-fill data for editing
    // if (widget.initialStudent != null) {
      _nameController.text = widget.initialStudent!.name ?? '';
      _placeController.text = widget.initialStudent!.place ?? '';
      _selectedGender = widget.initialStudent!.gender;
      _selectedDob = widget.initialStudent!.dob ?? '';
      _selectedAge = widget.initialStudent!.age ;
      _selectedClassId = widget.initialStudent!.classId;
      _initialImageBytes = widget.initialStudent!.profilePic;
    }
  }

  void _handleDateSelected(String dob, int age) {
    setState(() {
      _selectedDob = dob;
      _selectedAge = age;
    });
  }

  void _handleImageSelected(Uint8List? imageBytes, Function clearImage) {
    setState(() {
      _imageBytes = imageBytes;
      _clearImage = clearImage;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      id: widget.initialStudent?.id,
      name: _nameController.text,
      place: _placeController.text,
      gender: _selectedGender,
      dob: _selectedDob,
      age: _selectedAge,
      profilePic: _imageBytes ?? _initialImageBytes,
      classId: _selectedClassId,
    );

    if (isEdit == true) {
      await StudentService.editStudentDetails(student);
    } else {
      await StudentService.insertStudent(student.toMap());
    }

    _showSuccessMessage();
    _resetForm();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit == true 
            ? 'تم تحديث بيانات الطالب بنجاح' 
            : 'تم إضافة الطالب بنجاح'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,

      ),
    );
  }

  void _resetForm() {
    if (isEdit != true) {
      _formKey.currentState!.reset();
      _nameController.clear();
      _placeController.clear();
      _selectedGender = null;
      _selectedDob = '';
      _selectedAge = null;
      _selectedClassId = null;
      _clearImage?.call();
      _imageBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit == true ? 'تعديل طالب' : 'إضافة طالب '),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildNameField(),
              const SizedBox(height: 20),
              _buildPlaceField(),
              const SizedBox(height: 20),
              _buildGenderDropdown(),
              const SizedBox(height: 20),
              _buildClassDropdown(),
              const SizedBox(height: 20),
              CustomDateAndAgePicker(
                onDateSelected: _handleDateSelected,
                initialDateSaved: _selectedDob,
                initialAgeSaved: _selectedAge,
              ),
              const SizedBox(height: 20),
              ImageUpload(
                onSelectImage: _handleImageSelected,
                initialImageBytes: _initialImageBytes,
              ),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'اسم الطالب',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال اسم الطالب';
        }
        if (value.length < 3) {
          return 'يجب أن لا يقل الاسم عن 3 أحرف';
        }
        return null;
      },
    );
  }

  Widget _buildPlaceField() {
    return TextFormField(
      controller: _placeController,
      decoration: const InputDecoration(
        labelText: 'المنطقة',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال المنطقة';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'النوع',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      items: const [
        DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
        DropdownMenuItem(value: 'انثى', child: Text('انثى')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (value) => value == null ? 'يرجى اختيار النوع' : null,
    );
  }

  Widget _buildClassDropdown() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        return DropdownButtonFormField<int>(
          value: _selectedClassId,
          decoration: const InputDecoration(
            labelText: 'الفصل الدراسي',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.class_),
          ),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('اختر الفصل'),
            ),
            ...classProvider.classes.map((cls) {
              return DropdownMenuItem<int>(
                value: cls.id,
                child: Text(cls.name),
              );
            }).toList(),
          ],
          onChanged: (value) => setState(() => _selectedClassId = value),
          validator: (value) => value == null ? 'يرجى اختيار الفصل' : null,
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(isEdit == true ? Icons.update : Icons.add),
        label: Text(isEdit == true ? 'تحديث البيانات' : 'إضافة طالب'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: _submitForm,
      ),
    );
  }
}

