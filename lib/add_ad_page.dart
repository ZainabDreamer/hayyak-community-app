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

class AddAdPage extends StatefulWidget {
  final String neighborhoodId;
  const AddAdPage({super.key, required this.neighborhoodId});

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}

class _AddAdPageState extends State<AddAdPage> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

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

  Future<void> _submitAd() async {
    if (_titleController.text.trim().isEmpty ||
        _detailsController.text.trim().isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول أولاً');

      final uid = user.uid;

      final userUrl = Uri.parse(
        '$kDatabaseUrl/users/$uid.json',
      );
      final userRes = await http.get(userUrl);
      if (userRes.statusCode != 200) {
        throw Exception('فشل في جلب بيانات المستخدم');
      }
      final userData = json.decode(userRes.body);
      final username = userData['username'] ?? 'مستخدم';

      final imagePath = _imageFile?.path ?? '';

      final url = Uri.parse(
        '$kDatabaseUrl/communitys/${widget.neighborhoodId}.json',
      );

      final res = await http.post(
        url,
        body: json.encode({
          'category': 'إعلان',
          'title': _titleController.text.trim(),
          'text': _detailsController.text.trim(),    
          'details': _detailsController.text.trim(), 
          'location': _locationController.text.trim(),
          'price': _priceController.text.trim(),
          'image': imagePath,
          'username': username,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      setState(() => _isUploading = false);

      if (res.statusCode == 200 && mounted) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في نشر الإعلان')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

 
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
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
            const CustomHeaderAppBar(title: 'إضافة إعلان'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      children: [
                        _buildTextField(_titleController, 'عنوان الإعلان'),
                        _buildTextField(_detailsController, 'تفاصيل الإعلان', maxLines: 3),
                        _buildTextField(_locationController, 'الموقع'),
                        _buildTextField(_priceController, 'السعر (اختياري)', keyboardType: TextInputType.number),

                        // كارد اختيار/معاينة الصورة
                        Container(
                          margin: const EdgeInsets.only(top: 6, bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 10,
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.add_photo_alternate_outlined,
                                                size: 36, color: Colors.black54),
                                            SizedBox(height: 8),
                                            Text('اضغط لاختيار صورة',
                                                style: TextStyle(color: Colors.black54)),
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

                       
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _submitAd,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.campaign_outlined,
                                    color: Colors.white, size: 18),
                            label: Text(
                              _isUploading ? 'جارٍ النشر...' : 'نشر الإعلان',
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
                              minimumSize: const Size(293.31, 48), 
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

      
        bottomNavigationBar: const CustomBottomNav(
          currentIndex: 1,
          activeItem: 'community',
        ),
      ),
    );
  }
}
