// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_drawer.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController neighborhoodController;
  late TextEditingController birthdateController;

  String? selectedGender;
  DateTime? selectedDate;

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    firstNameController = TextEditingController(text: user['firstName']);
    lastNameController = TextEditingController(text: user['lastName']);
    emailController = TextEditingController(text: user['email']);
    phoneController = TextEditingController(text: user['phone']);
    cityController = TextEditingController(text: user['city']);
    neighborhoodController = TextEditingController(text: user['neighborhood']);
    birthdateController = TextEditingController(text: user['birthdate']);
    selectedGender = user['gender'];
  }

  void saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'city': cityController.text,
        'neighborhood': neighborhoodController.text,
        'birthdate': birthdateController.text,
        'gender': selectedGender,
        'createdAt': widget.user['createdAt'],
        'favorites': widget.user['favorites'] ?? [],
        'profileImage': widget.user['profileImage'] ?? '',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات')),
      );
      Navigator.pop(context, updatedUser);
    }
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        birthdateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8F7F7), Color(0xFFDFF5F4)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ⛳️ الهيدر (مطابق لصفحات الأدمن)
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black, size: 26),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      tooltip: 'القائمة',
                    ),
                  ),
                  title: SizedBox(
                    height: 44,
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 8.0),
                      child: Icon(Icons.notifications_none, color: Colors.black, size: 24),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: _buildFormCard(context),
                      ),
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

  Widget _buildFormCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF6FBFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: kCardShadow, blurRadius: 14, offset: Offset(0, 8)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عنوان الصفحة
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  //Icon(Icons.edit_note, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    ' ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grid حقول — محاذاة عربية كاملة
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 560;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _LabeledField(
                        label: 'الاسم الأول',
                        child: _buildTextField(firstNameController, hint: 'اكتب الاسم الأول', icon: Icons.badge_outlined),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'اسم العائلة',
                        child: _buildTextField(lastNameController, hint: 'اكتب اسم العائلة', icon: Icons.badge),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'البريد الإلكتروني',
                        child: _buildTextField(emailController, hint: 'example@mail.com', keyboardType: TextInputType.emailAddress, icon: Icons.alternate_email),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'رقم الجوال',
                        child: _buildTextField(phoneController, hint: '05xxxxxxxx', keyboardType: TextInputType.phone, icon: Icons.phone_iphone),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'المدينة',
                        child: _buildTextField(cityController, hint: 'اسم المدينة', icon: Icons.location_city),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'الحي',
                        child: _buildTextField(neighborhoodController, hint: 'اسم الحي', icon: Icons.map_outlined),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'تاريخ الميلاد',
                        child: GestureDetector(
                          onTap: () => _selectBirthdate(context),
                          child: AbsorbPointer(
                            child: _buildTextField(birthdateController, hint: 'يوم-شهر-سنة', icon: Icons.event_available),
                          ),
                        ),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                      _LabeledField(
                        label: 'الجنس',
                        child: _buildGenderDropdown(),
                        width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C8E97),
                    foregroundColor: Colors.white, // نص أبيض
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: saveChanges,
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text('حفظ', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C8E97), width: 1.5),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      icon: const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C8E97), width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'أنثى', child: Align(alignment: Alignment.centerRight, child: Text('أنثى'))),
        DropdownMenuItem(value: 'ذكر', child: Align(alignment: Alignment.centerRight, child: Text('ذكر'))),
      ],
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
      validator: (value) => value == null ? 'يرجى اختيار الجنس' : null,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final double width;

  const _LabeledField({
    required this.label,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C8E97),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
