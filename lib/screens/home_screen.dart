// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sc14/screens/show_deger.dart';
import '../providers/class_provaider.dart';
import '../we/we.dart';
import 'add_grades_screean.dart';
import 'add_students_screen.dart';
import 'attendance_page.dart';
import 'attendancepage.dart';
import 'mang_class_screen.dart';
import 'view_students_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
// final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          
          padding: EdgeInsets.zero,
          children: [
  const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2E4053),
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("image/logo.jpeg"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Scholl Master pro',
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text('عن التطبيق'),
              onTap:() =>Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CardSelectionUI()),),
            ),         
           
     
          ],
        ),
        
      ),


      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('نظام إدارة المدرسة',
                  style: TextStyle(
                    fontSize: 20,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                  )),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey[800]!,
                      Colors.blueGrey[600]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader('الإدارة الأكاديمية', Icons.school),
                  const SizedBox(height: 15),
                  _buildMainGrid(context, isWideScreen),
                  const SizedBox(height: 25),
                  _buildHeader('الإدارة الإدارية', Icons.manage_accounts),
                  const SizedBox(height: 15),
                  _buildSecondaryGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Color.fromARGB(255, 7, 28, 39), size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMainGrid(BuildContext context, bool isWideScreen) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWideScreen ? 3 : 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
                _buildFeatureCard(
          icon: Icons.class_,
          title: 'إدارة الفصول',
          color: Colors.deepOrange[600]!,
          onTap: () => _navigateToManageClasses(context),
        ),
        _buildFeatureCard(
          icon: Icons.group_add,
          title: 'إضافة طالب',
          color: Colors.teal[700]!,
          onTap: () => _navigateToAddStudent(context),
        ),
                _buildFeatureCard(
          icon: Icons.assignment_ind,
          title: 'كشف الحضور',
          color: Colors.orange[700]!,
          onTap: () => _navigateToAttendance(context),
        ),

        _buildFeatureCard(
          icon: Icons.grading,
          title: 'تسجيل الدرجات',
          color: Colors.purple[600]!,
          onTap: () => _navigateToAddGrades(context),
        ),
      ],
    );
  }

  Widget _buildSecondaryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
   
        _buildFeatureCard(
          icon: Icons.bar_chart,
          title: 'تقارير الدرجات',
          color: Colors.green[600]!,
          onTap: () => _navigateToGradesReport(context),
        ),

             _buildFeatureCard(
          icon: Icons.list_alt,
          title: 'قائمة الطلاب',
          color: Colors.blue[600]!,
          onTap: () => _navigateToStudentsList(context),
        ),



        _buildFeatureCard(
          icon: Icons.analytics,
          title: 'تقارير الحضور ',
          color: Colors.pink[600]!,
          onTap: () => _reporte_attendeant(context),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.9), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentsScreen()),
    );
  }

  void _navigateToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AttendancePage()),
    );
  }

  void _navigateToAddGrades(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGradesScreen()),
    );
  }

  void _navigateToStudentsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  ClassBasedStudentsScreen(1)),
    );
  }

  void _navigateToGradesReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GradesReportScreen()),
    );
  }

  void _navigateToManageClasses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  ManageClassesScreen()),
    );
  }

    void _reporte_attendeant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdvancedAttendanceReport()),
    );
  }
}