import 'package:flutter/material.dart';
import '../models/student_data.dart';

class StudentDeleteUndoSheet extends StatelessWidget {
  final Student student;
  final Function onUndoDelete;

  const StudentDeleteUndoSheet({
    super.key,
    required this.student,
    required this.onUndoDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Adjust height as needed
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Student "${student.name}" deleted.'),
            TextButton(
              onPressed: () {
                onUndoDelete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Student "${student.name}" restored.'),
                  ),
                );
              }, //onUndoDelete,
              child: Text(
                'Undo',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
