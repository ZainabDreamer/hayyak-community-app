// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';

class SafeRoutesPage extends StatelessWidget {
  const SafeRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المسارات الآمنة')),
      body: const Center(
        child: Text('هنا سيتم عرض المسارات الآمنة 🚶‍♀️'),
      ),
    );
  }
}
