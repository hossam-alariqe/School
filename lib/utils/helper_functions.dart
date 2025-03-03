import 'package:flutter/material.dart';

import 'dart:typed_data';

// Helper function to show profile picture dialog
void showProfilePictureDialog(BuildContext context, Uint8List profilePic) {
  try {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(profilePic),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  } catch (error) {
    print('Error showing profile picture: $error');
    // Optionally, display a snackbar to the user
  }
}
