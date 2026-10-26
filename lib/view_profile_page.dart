// By : Maha
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'profile_page.dart';

class ViewAccountPage extends StatefulWidget {
  const ViewAccountPage({super.key});

  @override
  State<ViewAccountPage> createState() => _ViewAccountPageState();
}

class _ViewAccountPageState extends State<ViewAccountPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String? profileImage;
  String fullName = 'مستخدم';
  String email = '';
  DateTime? creationDate;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (currentUser == null) return;

    final uid = currentUser!.uid;
    final url = Uri.parse(
        '$kDatabaseUrl/users/$uid.json');

    final response = await http.get(url);
    if (!mounted) return;
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fullName =
            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        if (fullName.isEmpty) fullName = 'مستخدم';
        email = data['email'] ?? currentUser!.email ?? '';
        profileImage = data['profileImage'];
        creationDate = currentUser!.metadata.creationTime;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month];
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text(
            "هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء."),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("حذف"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await currentUser?.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف الحساب بنجاح")),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في حذف الحساب")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

        
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  final scaffoldState = Scaffold.maybeOf(ctx);
                  if (scaffoldState?.hasDrawer ?? false) {
                    scaffoldState!.openDrawer();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
                tooltip: 'القائمة',
              ),
            ),
            title: SizedBox(
              height: 36,
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            actions: const [
              Padding(
                padding: EdgeInsetsDirectional.only(end: 8),
                child: Icon(Icons.notifications_none, color: Colors.black),
              ),
            ],
          ),

          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: constraints.maxHeight > 640
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // ← في الوسط
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
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
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 24, 20, 24),
                                  child: Column(
                                    children: [
                                      // الصورة + الاسم + البريد + التاريخ
                                      Center(
                                        child: CircleAvatar(
                                          radius: 55,
                                          backgroundColor:
                                              Colors.grey.shade300,
                                          backgroundImage: (profileImage !=
                                                      null &&
                                                  File(profileImage!)
                                                      .existsSync())
                                              ? FileImage(File(profileImage!))
                                              : const AssetImage(
                                                      'assets/images/default_profile.png')
                                                  as ImageProvider,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        fullName,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "عضو منذ ${formatDate(creationDate)}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(height: 24),

                                      _buildActionTile(
                                        icon: Icons.person_outline,
                                        label: "عرض معلوماتي الخاصة",
                                        color: const Color(0xFF2C8E97),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ProfilePage(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildActionTile(
                                        icon: Icons.delete_outline,
                                        label: "حذف الحساب",
                                        color: Colors.redAccent,
                                        onTap: _confirmDeleteAccount,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
