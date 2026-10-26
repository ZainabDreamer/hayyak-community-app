// By : Zainab
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeIntroPage extends StatefulWidget {
  const HomeIntroPage({super.key});

  @override
  State<HomeIntroPage> createState() => _HomeIntroPageState();
}

class _HomeIntroPageState extends State<HomeIntroPage>
    with SingleTickerProviderStateMixin {
  final String fullText =
      'تطبيق "حيّك" هو وجهتك لاكتشاف أحياء مدينتك والتواصل مع مجتمعك ومشاركة أفكارك واحتياجاتك بسهولة.';
  String displayedText = '';

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  Future<void> _startTyping() async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => displayedText += fullText[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // صورة الخلفية
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_intro.jpg', 
              fit: BoxFit.cover,
            ),
          ),

          // النص + الزر مع بعض
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.4), // أقرب للوسط
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // النص
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      displayedText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, 
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // زر الاستمرار الصغير
                  SizedBox(
                    height: 40,
                    width: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary, 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'الاستمرار',
                        style:
                            TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



