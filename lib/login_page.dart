// By: Areej + Lubna
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'admin_home_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;

  LinearGradient _bgGradient(BuildContext context) {
    // نفس حسّ السبلاش: فاتح ومنعش
    final cs = Theme.of(context).colorScheme;
    final c1 = Color.lerp(cs.primary, Colors.white, 0.85)!;
    final c2 = Color.lerp(cs.secondary, Colors.white, 0.90)!;
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [c1, c2],
    );
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoadingEmail = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final userId = credential.user?.uid;
      final url = Uri.parse(
          '$kDatabaseUrl/users/$userId.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final role = userData?['role'];

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => role == 'admin'
                ? const AdminHomePage()
                : const HomePage(),
          ),
        );
      } else {
        throw Exception('فشل في جلب بيانات المستخدم');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'حدث خطأ غير متوقع';
      if (e.code == 'user-not-found') msg = 'لا يوجد مستخدم بهذا البريد';
      if (e.code == 'wrong-password') msg = 'كلمة المرور غير صحيحة';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الدخول: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);
    try {
      final GoogleSignIn googleSignIn =
          GoogleSignIn(scopes: <String>['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الدخول: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل بريدك لإرسال رابط الاستعادة')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رابط إعادة التعيين لبريدك')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الإرسال: $e')),
      );
    }
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // شريط علوي بسيط
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.62,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                border: Border.all(
                                  color:
                                      Colors.white.withOpacity(0.35),
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
                              padding:
                                  const EdgeInsets.fromLTRB(20, 24, 20, 24),
                              child: _buildForm(primary),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Color primary) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          const Text(
            'تسجيل الدخول',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          // البريد
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'البريد الإلكتروني',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'أدخل البريد الإلكتروني';
              if (!v.contains('@')) return 'بريد غير صالح';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'example@gmail.com',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 16),

          // كلمة المرور
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'كلمة المرور',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: _obscurePassword,
            validator: (v) {
              if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
              if (v.length < 6) return 'على الأقل 6 أحرف';
              return null;
            },
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // نسيت كلمة المرور
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: _resetPassword,
              child: const Text(
                'هل نسيت كلمة المرور؟ اضغط هنا',
                style: TextStyle(
                  color: Color(0xFF2C8E97),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // زر تسجيل الدخول
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoadingEmail ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
              child: _isLoadingEmail
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('تسجيل الدخول',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),

          // فاصل
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('أو'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 14),

          // زر Google (شكل Outlined فاتح)
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _isLoadingGoogle ? null : _signInWithGoogle,
              icon: _isLoadingGoogle
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('تسجيل عن طريق Google'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.black.withOpacity(0.15)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // لا تملك حساب؟
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ليس لديك حساب؟'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                child: const Text(
                  'سجل الآن',
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
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
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
