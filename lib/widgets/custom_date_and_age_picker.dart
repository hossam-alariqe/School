import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateAndAgePicker extends StatefulWidget {
  final Function(String, int) onDateSelected;
  final String? initialDateSaved;
  final int? initialAgeSaved;

  const CustomDateAndAgePicker({
    super.key,
    required this.onDateSelected,
    this.initialDateSaved,
    this.initialAgeSaved,
  });

  @override
  _CustomDateAndAgePickerState createState() => _CustomDateAndAgePickerState();
}

class _CustomDateAndAgePickerState extends State<CustomDateAndAgePicker> {
  late TextEditingController _dobController;
  late TextEditingController _ageController;
  DateTime? _selectedDate;
  int? _age;

  @override
  void initState() {
    super.initState();
    _dobController = TextEditingController();
    _ageController = TextEditingController();
    _loadInitialValues();
  }

  void _loadInitialValues() {
    if (widget.initialDateSaved != null && widget.initialAgeSaved != null) {
      _selectedDate = DateFormat('dd-MM-yyyy').parse(widget.initialDateSaved!);
      _age = widget.initialAgeSaved;
      _updateControllers();
    }
  }

  void _updateControllers() {
    _dobController.text = _selectedDate != null
        ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
        : '';
    _ageController.text = _age?.toString() ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _age = _calculateAge(picked);
        _updateControllers();
        widget.onDateSelected(
          DateFormat('dd-MM-yyyy').format(picked),
          _age!,
        );
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'تاريخ الميلاد',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى اختيار تاريخ الميلاد';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _ageController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'العمر',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}