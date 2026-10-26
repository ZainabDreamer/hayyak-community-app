// By: Zainab 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'custom_drawer.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class AddPostPage extends StatefulWidget {
  final String neighborhoodId;

  const AddPostPage({super.key, required this.neighborhoodId});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _postController = TextEditingController();
  bool _isLoading = false;

  Future<void> submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');
      final uid = user.uid;

    
      final userUrl = Uri.parse(
        '$kDatabaseUrl/users/$uid.json',
      );
      final userResponse = await http.get(userUrl);
      if (userResponse.statusCode != 200) {
        throw Exception('فشل في جلب بيانات المستخدم');
      }
      final userData = json.decode(userResponse.body);
      final username = (userData['username'] ?? 'مستخدم').toString();

      
      final postUrl = Uri.parse(
        '$kDatabaseUrl/communitys/${widget.neighborhoodId}.json',
      );
      final postResponse = await http.post(
        postUrl,
        body: json.encode({
          'category': 'مشاركة',
          'text': text,
          'username': username,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (postResponse.statusCode == 200) {
        Navigator.pop(context, text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في الإرسال')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
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

        endDrawer: const CustomDrawer(),
        endDrawerEnableOpenDragGesture: true,

        drawer: const CustomDrawer(),
     

        body: SafeArea(
          child: Column(
            children: [
              const CustomHeaderAppBar(title: 'مشاركة جديدة'),

              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // الكارد
                          Container(
                            width: double.infinity,
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
                            padding: const EdgeInsets.all(12),
                            child: TextField(
                              controller: _postController,
                              maxLines: 8,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'اكتب شيئًا ملهمًا أو شارك فكرة...',
                                hintStyle:
                                    const TextStyle(color: Colors.black45),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(.15),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.black.withOpacity(.15),
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

                          const SizedBox(height: 24),

                          // الزر
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : submitPost,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_outlined,
                                      color: Colors.white, size: 20),
                              label: Text(
                                _isLoading ? 'جاري النشر...' : 'نشر المشاركة',
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                minimumSize:
                                    const Size.fromHeight(52), 
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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
        ),

        bottomNavigationBar: const CustomBottomNav(
          currentIndex: 1,
          activeItem: 'community',
        ),
      ),
    );
  }
}
