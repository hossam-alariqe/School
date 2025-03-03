import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provaider.dart';

class ManageClassesScreen extends StatefulWidget {
  @override
  _ManageClassesScreenState createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفصول'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ClassProvider>().loadClasses(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _classNameController,
                decoration:const  InputDecoration(
                  labelText: 'اسم الفصل الجديد',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الفصل';
                  }
                  return null;
                },
              ),
            ),
           const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label:const Text('إضافة فصل'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await context
                      .read<ClassProvider>()
                      .addClass(_classNameController.text);
                  _classNameController.clear();
                }
              },
            ),
           const SizedBox(height: 30),
            Expanded(
              child: Consumer<ClassProvider>(
                builder: (context, provider, _) => ListView.builder(
                  itemCount: provider.classes.length,
                  itemBuilder: (context, index) {
                    final schoolClass = provider.classes[index];
                    return Dismissible(
                      key: Key(schoolClass.id.toString()),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) =>
                          provider.deleteClass(schoolClass.id!),
                      child: Card(
                        child: ListTile(
                          title: Text(schoolClass.name),
                          trailing: const Icon(Icons.class_),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}