// By: Zainab
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 ألوان الهوية
class AppColors {
  static const Color primary = Color(0xFF1E9FB4); // فيروزي
  static const Color darkBlue = Color(0xFF0B4F6C); // أزرق داكن
  static const Color lightBlue = Color(0xFFB5E3E8); // أزرق سماوي فاتح
  static const Color mintGreen = Color(0xFFA8E6CF); // نجاح
  static const Color softYellow = Color(0xFFFFD972); // تحذير لطيف
  static const Color lightGrey = Color(0xFFF6F6F6); // خلفيات
  static const Color darkGrey = Color(0xFF555555);  // نص ثانوي
  static const Color errorRed = Color(0xFFFF6B6B);  // خطأ
}

///  تدرجات جاهزة لإعادة الاستخدام
class AppGradients {
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 208, 235, 239)],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.lightBlue],
  );
}

/// 🔠 أحجام وأنماط النصوص (موحدة لكل المشروع)
class AppText {
  // أحجام أساسية قابلة لإعادة الاستخدام
  static const double h1 = 24; // عناوين الصفحات
  static const double h2 = 20; // عناوين الأقسام
  static const double body = 16; // نصوص عامة
  static const double small = 13; // ملاحظات/تلميحات

  static TextTheme lightTextTheme(BuildContext context) {
    final base = Theme.of(context).textTheme;
    return GoogleFonts.cairoTextTheme(base).copyWith(
      titleLarge: TextStyle(fontSize: h1, fontWeight: FontWeight.w700, color: AppColors.darkBlue),
      titleMedium: TextStyle(fontSize: h2, fontWeight: FontWeight.w700, color: AppColors.darkBlue),
      bodyLarge: TextStyle(fontSize: body, color: AppColors.darkGrey),
      bodyMedium: TextStyle(fontSize: body, color: AppColors.darkGrey),
      bodySmall: TextStyle(fontSize: small, color: AppColors.darkGrey.withOpacity(.8)),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }

  static TextTheme darkTextTheme(BuildContext context) {
    final base = Theme.of(context).textTheme;
    return GoogleFonts.cairoTextTheme(base).copyWith(
      titleLarge: const TextStyle(fontSize: h1, fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: const TextStyle(fontSize: h2, fontWeight: FontWeight.w700, color: Colors.white),
      bodyLarge: const TextStyle(fontSize: body, color: Colors.white70),
      bodyMedium: const TextStyle(fontSize: body, color: Colors.white70),
      bodySmall: const TextStyle(fontSize: small, color: Colors.white60),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}

/// 🧩 الثيم الفاتح/الداكن
class AppTheme {
  static ThemeData light(BuildContext context) {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.lightBlue,
      surface: Colors.white,
      error: AppColors.errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightGrey,
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      textTheme: AppText.lightTextTheme(context),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // سنضع تدرجًا عبر ويدجت مخصص
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // سنلفّه بويدجت تدرج
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
     cardTheme: const CardThemeData(
  color: Colors.white,
  surfaceTintColor: Colors.white,
  margin: EdgeInsets.all(10),
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
),

    );
  }

  static ThemeData dark(BuildContext context) {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.lightBlue,
      surface: const Color(0xFF0F2A33),
      error: AppColors.errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF081C24),
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      textTheme: AppText.darkTextTheme(context),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
     cardTheme: const CardThemeData(
  color: Color(0xFF0F2A33),
  surfaceTintColor: Color(0xFF0F2A33),
  margin: EdgeInsets.all(10),
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
),

    );
  }
}

/// 🌟 AppBar بتدرج — استخدميه بدل AppBar العادي
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack ? const BackButton(color: Colors.white) : null,
      title: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
      actions: actions,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
      ),
    );
  }
}

/// 🔘 زر متدرّج عام — Drop-in replacement لـ ElevatedButton
class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GradientButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryButton,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero, // لأن البادينج بنحطه داخل الـ Ink
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryButton,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Container(
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
