import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../domain/request_model.dart';
import 'providers/request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _caseDescriptionController = TextEditingController();
  final _hospitalLocationController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedCity;
  int _unitsNeeded = 1;
  bool _isUrgent = false;
  bool _isLoading = false;
  String? _error;
  DateTime? _requiredDate;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> _cities = [
    'الرياض',
    'جدة',
    'الدمام',
    'مكة',
    'المدينة',
    'الطائف',
    'تبوك',
    'الخبر',
    'الظهران',
    'الأحساء',
    'جازان',
    'نجران',
    'حائل',
    'بريدة',
    'الخرج',
    'الخُبر',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _requiredDate) {
      setState(() {
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Validate required fields
      if (_selectedBloodType == null) {
        setState(() {
          _error = 'الرجاء اختيار فصيلة الدم';
        });
        return;
      }

      if (_selectedCity == null) {
        setState(() {
          _error = 'الرجاء اختيار المدينة';
        });
        return;
      }

      if (_hospitalLocationController.text.trim().isEmpty) {
        setState(() {
          _error = 'الرجاء إدخال عنوان المستشفى';
        });
        return;
      }

      if (_patientNameController.text.trim().isEmpty) {
        setState(() {
          _error = 'الرجاء إدخال اسم المريض';
        });
        return;
      }

      if (_hospitalNameController.text.trim().isEmpty) {
        setState(() {
          _error = 'الرجاء إدخال اسم المستشفى';
        });
        return;
      }

      if (_contactNumberController.text.trim().isEmpty) {
        setState(() {
          _error = 'الرجاء إدخال رقم التواصل';
        });
        return;
      }

      if (_caseDescriptionController.text.trim().isEmpty) {
        setState(() {
          _error = 'الرجاء إدخال وصف الحالة';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final requestProvider = Provider.of<RequestProvider>(
        context,
        listen: false,
      );
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final request = BloodRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: _patientNameController.text.trim(),
        bloodType: _selectedBloodType!,
        hospitalName: _hospitalNameController.text.trim(),
        city: _selectedCity!,
        contactNumber: _contactNumberController.text.trim(),
        caseDescription: _caseDescriptionController.text.trim(),
        hospitalLocation: _hospitalLocationController.text.trim(),
        unitsNeeded: _unitsNeeded,
        unitsDonated: 0,
        isUrgent: _isUrgent,
        requiredDate: _requiredDate,
        createdAt: DateTime.now(),
        createdBy: authProvider.user?.uid ?? 'anonymous',
      );

      await requestProvider.addRequest(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل إرسال الطلب: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalNameController.dispose();
    _contactNumberController.dispose();
    _caseDescriptionController.dispose();
    _hospitalLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلب تبرع جديد'), centerTitle: true),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _error = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Patient Name
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المريض',
                    hintText: 'أدخل اسم المريض بالكامل',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المريض';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Blood Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: const InputDecoration(
                    labelText: 'فصيلة الدم',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _bloodTypes.map((String bloodType) {
                    return DropdownMenuItem<String>(
                      value: bloodType,
                      child: Text(bloodType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار فصيلة الدم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Hospital Name
                TextFormField(
                  controller: _hospitalNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستشفى',
                    hintText: 'أدخل اسم المستشفى',
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المستشفى';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'المدينة',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار المدينة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contact Number
                TextFormField(
                  controller: _contactNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم التواصل',
                    hintText: 'أدخل رقم الجوال للتواصل',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم التواصل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Case Description
                TextFormField(
                  controller: _caseDescriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف الحالة',
                    hintText: 'أدخل وصفًا تفصيليًا لحالة المريض',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف الحالة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Hospital Location
                TextFormField(
                  controller: _hospitalLocationController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المستشفى',
                    hintText: 'أدخل عنوان المستشفى بالتفصيل',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان المستشفى';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Units Needed
                Row(
                  children: [
                    const Text(
                      "عدد الوحدات المطلوبة:",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_unitsNeeded > 1) {
                                setState(() {
                                  _unitsNeeded--;
                                });
                              }
                            },
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_unitsNeeded',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _unitsNeeded++;
                              });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Required Date
                InkWell(
                  onTap: _isLoading ? null : () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الحاجة للدم',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _requiredDate == null
                              ? 'اختر التاريخ'
                              : '${_requiredDate!.year}/${_requiredDate!.month}/${_requiredDate!.day}',
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Urgent Checkbox
                CheckboxListTile(
                  title: const Text(
                    'حالة طارئة',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: _isUrgent,
                  onChanged: _isLoading
                      ? null
                      : (bool? value) {
                          setState(() {
                            _isUrgent = value ?? false;
                          });
                        },
                  secondary: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.red,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'إرسال الطلب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
