// By: Zainab 
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'custom_drawer.dart'; // 
import 'package:firebase_auth/firebase_auth.dart';

class AddPhotoPage extends StatefulWidget {
  final String neighborhoodId;

  const AddPhotoPage({super.key, required this.neighborhoodId});

  @override
  State<AddPhotoPage> createState() => _AddPhotoPageState();
}

class _AddPhotoPageState extends State<AddPhotoPage> {
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _uploadAndSubmit() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

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

      
      final imagePath = _imageFile!.path;

     
      final url = Uri.parse(
        '$kDatabaseUrl/communitys/${widget.neighborhoodId}.json',
      );
      final response = await http.post(
        url,
        body: json.encode({
          'category': 'صورة',
          'image': imagePath,
          'username': username,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      setState(() => _isUploading = false);

      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context, imagePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في حفظ الصورة')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
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
        drawer: const CustomDrawer(), // 
        body: Column(
          children: [
            const CustomHeaderAppBar(title: 'إضافة صورة للحي'),

            // المحتوى
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    // كارد اختيار/معاينة الصورة في الوسط
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
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _imageFile == null
                                ? Container(
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add_a_photo_outlined,
                                            size: 36, color: Colors.black54),
                                        SizedBox(height: 8),
                                        Text('اضغط لاختيار صورة',
                                            style: TextStyle(
                                                color: Colors.black54)),
                                      ],
                                    ),
                                  )
                                : Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                   
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadAndSubmit,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined,
                                color: Colors.white, size: 18),
                        label: Text(
                          _isUploading ? 'جارٍ الرفع...' : 'نشر الصورة',
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
                          minimumSize: const Size(293.31, 44), 
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
          ],
        ),

       
        bottomNavigationBar:
            const CustomBottomNav(currentIndex: 1, activeItem: 'community'),
      ),
    );
  }
}
