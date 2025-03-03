// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';

import '../models/student_data.dart';
import '../utils/helper_functions.dart';
import 'add_students_screen.dart';

class ViewStudentsDetailsScreen extends StatefulWidget {
  const ViewStudentsDetailsScreen({super.key, required this.studentDetail});

  final Student studentDetail;

  @override
  State<ViewStudentsDetailsScreen> createState() =>
      _ViewStudentsDetailsScreenState();
}

class _ViewStudentsDetailsScreenState extends State<ViewStudentsDetailsScreen> {
//  final _formKey = GlobalKey<FormState>(); // Form key for validation
//  late Student _editedStudent = widget.studentDetail; // Copy of student data
//  bool _isEditEnabled = false; // Flag to enable/disable edit form

  // ignore: unused_field
  bool _detailsUpdated = false;

  Student? updatedStudent;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        Navigator.pop(context, updatedStudent);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.studentDetail.name ?? 'Student Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.studentDetail.profilePic != null)
                GestureDetector(
                  onTap: () {
                    showProfilePictureDialog(
                        context, widget.studentDetail.profilePic!);
                  },
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          MemoryImage(widget.studentDetail.profilePic!),
                    ),
                  ),
                )
              else
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text('الاسم : ${widget.studentDetail.name ?? 'N/A'}'),
              Text('المنطقة : ${widget.studentDetail.place ?? 'N/A'}'),
              Text('النوع : ${widget.studentDetail.gender ?? 'N/A'}'),
              Text(' تاريخ الميلاد  :  ${widget.studentDetail.dob ?? 'N/A'}'),
              Text('العمر : ${widget.studentDetail.age ?? 'N/A'}'),
              // Text('id is: ${widget.studentDetail.id ?? 'N/A'}'),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  // Navigate to AddStudentScreen with student details for editing
                  updatedStudent = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStudentsScreen(
                        initialStudent: widget.studentDetail,
                        // isEditt: true, // Flag for editing mode
                      ),
                    ),
                  );
                  if (updatedStudent != null) {
                    // Update successful (handle the updated student data)
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text('Student updated successfully'),
                    //     duration: Duration(seconds: 2),
                    //   ),
                    // );
                    // Update UI with changes if needed
                    setState(
                      () {
                        widget.studentDetail.name = updatedStudent!.name;
                        widget.studentDetail.place = updatedStudent!.place;
                        widget.studentDetail.dob = updatedStudent!.dob;
                        widget.studentDetail.gender = updatedStudent!.gender;
                        widget.studentDetail.age = updatedStudent!.age;
                        widget.studentDetail.profilePic =
                            updatedStudent!.profilePic;
                      },
                    );

                    // Pass the updated student back to the list screen
                    //   Navigator.pop(context, updatedStudent);
                    // Pass the updated student back to the list screen
                    _detailsUpdated = true;
                  }
                },
                child: const Text('تعديل ملف الطالب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
