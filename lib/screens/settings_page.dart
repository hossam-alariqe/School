// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الإعدادات'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildLanguageSetting(context),
//           const Divider(),
//           _buildAppInfo(context),
//         ],
//       ),
//     );
//   }


//   Widget _buildLanguageSetting(BuildContext context) {
//     return ListTile(
//       leading: const Icon(Icons.language),
//       title: const Text('اللغة'),
//       trailing: DropdownButton<String>(
//         value: Provider.of<LocaleProvider>(context).currentLocale,
//         items: const [
//           DropdownMenuItem(
//             value: 'ar',
//             child: Text('العربية'),
//           ),
//           DropdownMenuItem(
//             value: 'en',
//             child: Text('English'),
//           ),
//         ],
//         onChanged: (value) => _changeLanguage(context, value!),
//       ),
//     );
//   }

//   Widget _buildAppInfo(BuildContext context) {
//     return const ListTile(
//       leading: Icon(Icons.info),
//       title: Text('معلومات التطبيق'),
//       subtitle: Text('الإصدار 1.0.0'),
//     );
//   }

//   void _changeLanguage(BuildContext context, String langCode) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('language', langCode);
//     Provider.of<LocaleProvider>(context, listen: false).setLocale(langCode);
//   }
// }

// class LocaleProvider extends ChangeNotifier {
//   String _locale = 'ar';

//   String get currentLocale => _locale;

//   void setLocale(String locale) {
//     _locale = locale;
//     notifyListeners();
//   }
// }