import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function onCancel;
  final Function onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => onCancel(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => onConfirm(context),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}



// class ConfirmationDialog extends StatelessWidget {
//   const ConfirmationDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Confirm Delete'),
//       content: Text('Are you sure you want to delete ${student.name}'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, false),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context, true),
//           child: const Text('Delete'),
//         ),
//       ],
//     );
//   }
// }