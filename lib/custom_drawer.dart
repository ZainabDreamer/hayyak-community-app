// By : Lubna + Maha
import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hayyak/view_profile_page.dart' show ViewAccountPage;
import 'package:http/http.dart' as http;
import 'contact_page.dart' ;
import 'fav_page.dart';
import 'chat_page.dart';
import 'setting_page.dart';
import 'login_page.dart';
import 'dart:io';
class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  Future<void> getCurrentUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final url = Uri.parse(
          '$kDatabaseUrl/users.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final matchingEntry = data.entries.firstWhere(
              (entry) => entry.value['email'] == currentUser!.email,
          orElse: () => MapEntry('', {}),
        );

        if (matchingEntry.value.isNotEmpty) {
          setState(() {
            userData = matchingEntry.value;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = userData?['firstName'] ?? 'مستخدم';
    final String imageUrl = userData?['profileImage'] ?? '';

    return Drawer(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.7,
      child: Container(
        color: const Color(0xFF2C8E97),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: (imageUrl.isNotEmpty && File(imageUrl).existsSync())
                        ? FileImage(File(imageUrl))
                        : null,
                    child: (imageUrl.isEmpty || !File(imageUrl).existsSync())
                        ? const Icon(Icons.person, color: Color(0xFF2C8E97), size: 30)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أهلاً $name',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 23),
                      ),
                      Text(
                        'حياك الله ',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewAccountPage()));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(12))),
                        ),
                        child: const Text(
                            'عرض حسابي', style: TextStyle(color: Color(
                            0xFF2C8E97))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildDrawerItem(Icons.favorite, 'المفضلة', context, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const FavPage()));
            }),

            _buildDrawerItem(Icons.chat, 'محادثاتي', context, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ChatPage()));
            }),

            _buildDrawerItem(Icons.call, 'تواصل معنا', context, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ContactPage()));
            }),

            _buildDrawerItem(Icons.settings, 'الإعدادات', context, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
            }),

            _buildDrawerItem(Icons.logout, 'تسجيل الخروج', context, () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context,
      VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // يغلق القائمة أولاً
        onTap(); // ثم ينفذ التنقل
      },
    );
  }

}
