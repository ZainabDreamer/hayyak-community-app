// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'dart:convert';
import 'config.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'contact_requests_page.dart';
import 'users_page.dart';
import 'admin_neighborhoods_page.dart';
import 'adminreviews_page.dart';
import 'custom_drawer.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String? profileImage;
  String fullName = '...';
  String role = '...';

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    if (currentUser == null) return;

    final uid = currentUser!.uid;
    final url = Uri.parse(
        '$kDatabaseUrl/users/$uid.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          role = data['role'] ?? 'غير محدد';
          profileImage = data['profileImage'];
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                // الهيدر ثابت في الأعلى كما السابق
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
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 255, 255, 255).withOpacity(0.95),
                                    Color(0xFFEAF9F9).withOpacity(0.95)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: kCardShadow,
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: (profileImage != null && profileImage!.isNotEmpty)
                                        ? FileImage(File(profileImage!))
                                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'أهلًا $fullName',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          role,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ].reversed.toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          buildAdminCard(
                            context,
                            image: 'assets/images/users.png',
                            title: 'المستخدمين',
                            color: const Color(0xFFF2FCFC),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const UsersPage()),
                              );
                            },
                          ),
                          buildAdminCard(
                            context,
                            image: 'assets/images/location.png',
                            title: 'الأحياء',
                            color: const Color(0xFFF6FBFB),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NeighborhoodsPage()),
                              );
                            },
                          ),
                          buildAdminCard(
                            context,
                            image: 'assets/images/comments.png',
                            title: 'التعليقات',
                            color: const Color(0xFFF0F6FA),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ReviewsPage()),
                              );
                            },
                          ),
                          buildAdminCard(
                            context,
                            image: 'assets/images/contact.png',
                            title: 'إدارة الشكاوي',
                            color: const Color(0xFFF5FAF9),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ContactRequestsPage()),
                              );
                            },
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: const CustomDrawer(),
      ),
    );
  }

  Widget buildAdminCard(
    BuildContext context, {
    required String image,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: kCardShadow,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Image.asset(image, width: 72, height: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ].reversed.toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

