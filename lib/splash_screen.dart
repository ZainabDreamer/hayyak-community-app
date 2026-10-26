// By: Zainab
// Design in Flutter : Zainab Alaujami
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'home_intro.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // الانتقال لاحقًا 
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeIntroPage()),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/logo.png'), context);
    precacheImage(const AssetImage('assets/images/amanah_logo.png'), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _bgGradient(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFFE8F7F7), Color(0xFFDFF5F4)],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double partnerLogoWidth = 48.0; // شعار الأمانة

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _bgGradient(context)),
        child: Stack(
          children: [
            // شعار التطبيق + الجملة المتحركة
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Hero(
                        tag: 'app_logo',
                        child: Image(
                          image: AssetImage('assets/images/logo.png'),
                          width: 120,
                        ),
                      ),
                      const SizedBox(height: 4), 
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'استكشف مجتمعك وشارك أفكارك',
                            textStyle: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: Duration.zero,
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 160,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: Colors.black.withOpacity(.08),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 8),
                   // Image.asset(
                     // 'assets/images/amanah_logo.png',
                     // width: partnerLogoWidth,
                      //fit: BoxFit.contain,
                    //),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


