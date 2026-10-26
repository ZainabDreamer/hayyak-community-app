import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme_provider.dart';        
import 'theme.dart';                
import 'splash_screen.dart';
import 'home_page.dart';
import 'community_page.dart';
import 'path_search_page.dart';
import 'setting_page.dart';
import 'chat_page.dart';
import 'fav_page.dart';
import 'details_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const HayyakApp(),
    ),
  );
}

class HayyakApp extends StatelessWidget {
  const HayyakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'حيّك',
      debugShowCheckedModeBanner: false,

     
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      //  تطبيق الثيم المركزي من theme.dart
      themeMode: themeProvider.currentTheme,
      theme: AppTheme.light(context),
      darkTheme: AppTheme.dark(context),

      //  التوجيهات
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/home': (_) => const HomePage(),
        '/community': (_) => const CommunityPage(),
        '/routes': (_) => const PathSearchPage(),
        '/settings': (_) => const SettingsPage(),
        '/chat': (_) => const ChatPage(),
        '/favorites': (_) => const FavPage(),
        '/details': (_) => const DetailsHomePage(neighborhood: {}),
      },
    );
  }
}
