// By: Zainab 
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart'; // 


class AddNeedPage extends StatefulWidget {
  final String neighborhoodId;

  const AddNeedPage({super.key, required this.neighborhoodId});

  @override
  State<AddNeedPage> createState() => _AddNeedPageState();
}

class _AddNeedPageState extends State<AddNeedPage> {
  final TextEditingController _needController = TextEditingController();
  bool _isLoading = false;

  Future<void> submitNeed() async {
    final text = _needController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("يجب تسجيل الدخول أولاً");

      final uid = user.uid;

      final userUrl = Uri.parse(
        '$kDatabaseUrl/users/$uid.json',
      );
      final userResponse = await http.get(userUrl);
      if (userResponse.statusCode != 200) {
        throw Exception("فشل في جلب بيانات المستخدم");
      }
      final userData = json.decode(userResponse.body);
      final username = userData['username'] ?? 'مستخدم';

      final url = Uri.parse(
        '$kDatabaseUrl/communitys/${widget.neighborhoodId}.json',
      );

      final response = await http.post(
        url,
        body: json.encode({
          'category': 'احتياج',
          'text': text,
          'username': username,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في الإرسال')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

       
        drawer: const CustomDrawer(),

        body: Column(
          children: [
            const CustomHeaderAppBar(title: 'إضافة احتياج'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: TextField(
                            controller: _needController,
                            maxLines: 6,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'اكتب تفاصيل الاحتياج هنا...',
                              hintStyle:
                                  TextStyle(color: Colors.black.withOpacity(.45)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(.12),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(.12),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: accent, width: 1.5),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : submitNeed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(293.31, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'نشر الاحتياج',
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: const CustomBottomNav(
          currentIndex: 1,
          activeItem: 'community',
        ),
      ),
    );
  }
}
