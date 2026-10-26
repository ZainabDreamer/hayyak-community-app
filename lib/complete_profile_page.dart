// By : Areej + Lubna
// Design in Flutter : Zainab Alaujami
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home_page.dart' show HomePage;

class CompleteProfilePage extends StatefulWidget {
  final String userId;
  const CompleteProfilePage({super.key, required this.userId});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final _database = FirebaseDatabase.instance.ref();

  File? _image;
  final picker = ImagePicker();
  bool agreeTerms = false;
  bool _isSaving = false;

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  InputDecoration _inputDecoration(BuildContext context,
      {required String hint, IconData? icon}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.35), width: 1),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        width: 1.5,
      ),
    );
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[700]) : null,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: focusBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null || !agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة والموافقة على الشروط')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // تحقق من عدم تكرار اسم المستخدم
      final snapshot = await _database.child('users').once();
      final usersData = snapshot.snapshot.value as Map?;
      final username = usernameController.text.trim();

      if (usersData != null) {
        final isDuplicate = usersData.values.any((user) {
          if (user is Map) {
            return (user['username']?.toString().toLowerCase() ==
                username.toLowerCase());
          }
          return false;
        });
        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('اسم المستخدم مستخدم بالفعل، اختر اسمًا آخر')),
          );
          return;
        }
      }

      // مبدئيًا نخزن مسار الملف المحلي (يفضل لاحقًا رفعه لـ Storage وأخذ URL)
      await _database.child('users/${widget.userId}').update({
        'username': username,
        'profileImage': _image!.path,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
      
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFE8F7F7), Color(0xFFDFF5F4)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, 
          extendBody: true,                   
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Image.asset('assets/images/logo.png', width: 120),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 4),
                                const Text(
                                  'إكمال الملف الشخصي',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // صورة الحساب + زر تعديل
                                Center(
                                  child: Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      CircleAvatar(
                                        radius: 52,
                                        backgroundColor: const Color(0xFFE0E0E0),
                                        backgroundImage: _image != null
                                            ? FileImage(_image!)
                                            : null,
                                        child: _image == null
                                            ? const Icon(Icons.person,
                                                size: 52, color: Colors.white)
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Material(
                                          color: Colors.white,
                                          shape: const CircleBorder(),
                                          elevation: 2,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: _pickImage,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Icon(Icons.edit,
                                                  size: 18, color: primary),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 22),

                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'اسم الحساب',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: usernameController,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'أدخل اسم الحساب';
                                    }
                                    if (v.trim().length < 3) {
                                      return 'الاسم قصير جدًا';
                                    }
                                    return null;
                                  },
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'مثال: Areej_99',
                                    icon: Icons.badge_outlined,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // الشروط والأحكام
                                Row(
                                  children: [
                                    Checkbox(
                                      value: agreeTerms,
                                      onChanged: (val) => setState(
                                          () => agreeTerms = val ?? false),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => agreeTerms = !agreeTerms),
                                        child: const Text(
                                          'أوافق على الشروط والأحكام',
                                          style: TextStyle(
                                            color: Color(0xFF2C8E97),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // زر تسجيل/حفظ
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 1,
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text('تسجيل',
                                            style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
