// By: Zainab 
// Design in Flutter : Zainab Alaujami
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'custom_drawer.dart'; 


class AdDetailsPage extends StatelessWidget {
  final String title;
  final String text;
  final String location;
  final String price;
  final String seller;
  final String? sellerPhone; //  رقم البائع (للاتصال أو واتساب)
  final String? imagePath;

  const AdDetailsPage({
    super.key,
    required this.title,
    required this.text,
    required this.location,
    required this.price,
    required this.seller,
    this.sellerPhone,
    this.imagePath,
  });

  /// فتح رابط خارجي (اتصال أو واتساب)
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw Exception('لا يمكن فتح الرابط: $url');
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
            const CustomHeaderAppBar(title: 'تفاصيل الإعلان'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة الإعلان
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
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: (imagePath != null &&
                                  imagePath!.isNotEmpty &&
                                  File(imagePath!).existsSync())
                              ? Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[100],
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.image,
                                    size: 56,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // بيانات الإعلان
                    _infoRow(Icons.title, 'عنوان الإعلان', title, accent),
                    _infoRow(Icons.description, 'وصف الإعلان', text, accent),
                    _infoRow(Icons.location_on, 'الموقع', location, accent),
                    _infoRow(Icons.attach_money, 'السعر', price, accent),
                    _infoRow(Icons.person, 'البائع', seller, accent),

                    const SizedBox(height: 20),

                    // أزرار التواصل (اتصال + واتساب)
                    if (sellerPhone != null && sellerPhone!.isNotEmpty) ...[
                      // اتصال مباشر
                      ElevatedButton.icon(
                        onPressed: () => _launchURL('tel:${sellerPhone!}'),
                        icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                        label: const Text(
                          'اتصال مباشر',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // فتح واتساب (باستخدام أيقونة محادثة)
                      ElevatedButton.icon(
                        onPressed: () {
                          final phone = sellerPhone!
                              .replaceAll('+', '')
                              .replaceAll(' ', '')
                              .replaceAll('-', '');
                          _launchURL('https://wa.me/$phone');
                        },
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                        label: const Text(
                          'فتح واتساب',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ],
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

  Widget _infoRow(IconData icon, String label, String value, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: accent)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

