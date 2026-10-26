// By: Areej + Lubna
// Design in Flutter : Zainab Alaujami
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'complete_profile_page.dart' show CompleteProfilePage;
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedCity;
  String? selectedNeighborhood;

  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  bool _isLoadingSignup = false;

  LinearGradient _bgGradient(BuildContext context) {
    
    final cs = Theme.of(context).colorScheme;
    final c1 = Color.lerp(cs.primary, Colors.white, 0.85)!;
    final c2 = Color.lerp(cs.secondary, Colors.white, 0.90)!;
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [c1, c2],
    );
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showError('كلمة المرور غير متطابقة');
      return;
    }
    if (selectedCity == null || selectedNeighborhood == null) {
      _showError('يرجى اختيار المدينة والحي');
      return;
    }

    setState(() => _isLoadingSignup = true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      await _database.child('users/$userId').set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': email,
        'city': selectedCity,
        'neighborhood': selectedNeighborhood,
        'role': 'user',
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfilePage(userId: userId),
        ),
      );
    } catch (e) {
      _showError('فشل إنشاء الحساب: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSignup = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textDirection: TextDirection.rtl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: _bgGradient(context)),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // شريط علوي + سهم رجوع (نفس ستايل تسجيل الدخول)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_ios_new),
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // شعار
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
                        child: Container
                        (
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
                                  'تسجيل مستخدم جديد',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // الاسم الأول
                                _labeled('الاسم الأول'),
                                TextFormField(
                                  controller: firstNameController,
                                  validator: _req,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'اكتب اسمك الأول',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // الاسم الثاني
                                _labeled('الاسم الثاني'),
                                TextFormField(
                                  controller: lastNameController,
                                  validator: _req,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'اكتب اسمك الثاني',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // البريد الإلكتروني
                                _labeled('البريد الإلكتروني'),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
                                    if (!v.contains('@')) return 'بريد غير صالح';
                                    return null;
                                  },
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'example@gmail.com',
                                    icon: Icons.email_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // كلمة المرور
                                _labeled('كلمة المرور'),
                                StatefulBuilder(
                                  builder: (context, setSB) {
                                    bool obscure = true;
                                    return TextFormField(
                                      controller: passwordController,
                                      obscureText: obscure,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                                        if (v.length < 6) return 'على الأقل 6 أحرف';
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        context,
                                        hint: '••••••••',
                                        icon: Icons.lock_outline,
                                      ).copyWith(
                                        suffixIcon: _PasswordToggle(
                                          onToggle: () => setSB(() => obscure = !obscure),
                                          isObscure: obscure,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                // تأكيد كلمة المرور
                                _labeled('تأكيد كلمة المرور'),
                                TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                                    if (v != passwordController.text) return 'كلمة المرور غير متطابقة';
                                    return null;
                                  },
                                  decoration: _inputDecoration(
                                    context,
                                    hint: '••••••••',
                                    icon: Icons.lock_reset_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // المدينة
                                _labeled('اختر المدينة'),
                                DropdownButtonFormField<String>(
                                  value: selectedCity,
                                  items: const [
                                    DropdownMenuItem(value: 'الدمام', child: Text('الدمام')),
                                    DropdownMenuItem(value: 'الخبر', child: Text('الخبر')),
                                    DropdownMenuItem(value: 'القطيف', child: Text('القطيف')),
                                  ],
                                  onChanged: (val) => setState(() => selectedCity = val),
                                  validator: (v) => v == null ? 'الرجاء الاختيار' : null,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'اختر المدينة',
                                    icon: Icons.location_city_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // الحي
                                _labeled('اختر الحي الخاص بك'),
                                DropdownButtonFormField<String>(
                                  value: selectedNeighborhood,
                                  items: const [
                                    DropdownMenuItem(value: 'حي السلام', child: Text('حي السلام')),
                                    DropdownMenuItem(value: 'حي الفيصليه', child: Text('حي الفيصليه')),
                                    DropdownMenuItem(value: 'حي النورس', child: Text('حي النورس')),
                                    DropdownMenuItem(value: 'حي الشاطئ', child: Text('حي الشاطئ')),
                                    DropdownMenuItem(value: 'حي النور', child: Text('حي النور')),
                                    DropdownMenuItem(value: 'حي الراكة', child: Text('حي الراكة')),
                                  ],
                                  onChanged: (val) => setState(() => selectedNeighborhood = val),
                                  validator: (v) => v == null ? 'الرجاء الاختيار' : null,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'اختر الحي',
                                    icon: Icons.map_outlined,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // زر تسجيل
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoadingSignup ? null : _registerUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 1,
                                    ),
                                    child: _isLoadingSignup
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('تسجيل', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // لديك حساب؟ -> إلى تسجيل الدخول
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('لديك حساب؟'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const LoginPage()),
                                        );
                                      },
                                      child: const Text(
                                        'سجّل دخولك هنا',
                                        style: TextStyle(
                                          color: Color(0xFF2C8E97),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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

  // Label helper
  Widget _labeled(String label) => Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );

  // Required validator
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  // Input decoration (نفس تسجيل الدخول)
  InputDecoration _inputDecoration(BuildContext context,
      {required String hint, required IconData icon}) {
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
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: focusBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// أيقونة تبديل الرؤية لحقل الباسوورد داخل StatefulBuilder
class _PasswordToggle extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isObscure;
  const _PasswordToggle({required this.onToggle, required this.isObscure});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
    );
  }
}
