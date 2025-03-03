// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sc14/providers/class_provaider.dart';
import 'package:sc14/providers/student_provider.dart';
import 'package:sc14/screens/add_students_screen.dart';
import 'package:sc14/screens/home_screen.dart';
import 'package:sc14/screens/mang_class_screen.dart';
import 'package:sc14/splash_screen/splash_screen.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
            // ChangeNotifierProvider(create: (_) => GradeProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام إدارة المدرسة',
      theme: _buildAppTheme(),
      home: const ProfessionalSplashScreen(),
      routes: {
        '/add-student': (context) =>  const AddStudentsScreen(),
        '/manage-classes': (context) =>  ManageClassesScreen(),
        // '/attendance-report': (context) =>  AttendanceReportPage(),
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: _createMaterialColor(const Color(0xFF2E4053)),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        color: Color(0xFF2E4053),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E4053),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF4A4A4A),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E4053)),
        ),
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = [.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}