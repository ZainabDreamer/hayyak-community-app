// By: Zainab 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:hayyak/photo_gallery_page.dart' show FullScreenGalleryPage;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'addphoto_page.dart';
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'add_need_page.dart';
import 'add_ad_page.dart';
import 'post_details_page.dart';
import 'ad_details_page.dart';
import 'post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_drawer.dart';

class NeighborhoodPage extends StatefulWidget {
  final String neighborhoodId;
  final String neighborhoodName;
  final String neighborhoodImage;
  final String? neighborhoodInfo;
  final List<String>? events;

  const NeighborhoodPage({
    super.key,
    required this.neighborhoodId,
    required this.neighborhoodName,
    required this.neighborhoodImage,
    this.neighborhoodInfo,
    this.events,
  });

  @override
  State<NeighborhoodPage> createState() => _NeighborhoodPageState();
}

class _NeighborhoodPageState extends State<NeighborhoodPage> {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> opinions = [];
  List<Map<String, dynamic>> imageUrls = [];
  List<Map<String, dynamic>> needs = [];
  List<Map<String, dynamic>> ads = [];

  @override
  void initState() {
    super.initState();
    fetchCommunityContent();
  }

  Future<void> fetchCommunityContent() async {
    final url = Uri.parse(
        '$kDatabaseUrl/communitys/${widget.neighborhoodId}.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data == null) return;

      List<Map<String, dynamic>> newPosts = [];
      List<Map<String, dynamic>> newPhotos = [];
      List<Map<String, dynamic>> newNeeds = [];
      List<Map<String, dynamic>> newAds = [];
      List<Map<String, dynamic>> newOpinions = [];

      data.forEach((key, value) {
        if (value is! Map) return;

        final category = value['category'];

        if (category == 'مشاركة' && value['text'] != null) {
          newPosts.add({
            'id': key,
            'text': value['text'],
            'createdAt': value['createdAt'],
            'username': value['username'] ?? 'مستخدم',
          });
        } else if (category == 'صورة' && value['image'] != null) {
          newPhotos.add({
            'image': value['image'],
            'username': value['username'] ?? 'مستخدم',
          });
        } else if (category == 'احتياج' && value['text'] != null) {
          newNeeds.add({
            'text': value['text'],
            'username': value['username'] ?? 'مستخدم',
          });
        } else if (category == 'إعلان') {
          newAds.add({
            'id': key,
            'title': value['title'] ?? '',
            'text': value['text'] ?? '',
            'location': value['location'] ?? '',
            'price': value['price'] ?? '',
            'seller': value['seller'] ?? '',
            'image': value['image'],
            'username': value['username'] ?? 'مستخدم',
          });
        } else if (category == 'رأي' && value['text'] != null) {
          newOpinions.add({
            'text': value['text'],
            'username': value['username'] ?? 'مستخدم',
          });
        }
      });

      setState(() {
        posts = newPosts;
        imageUrls = newPhotos;
        needs = newNeeds;
        ads = newAds;
        opinions = newOpinions;
      });
    }
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await fetchCommunityContent();
  }

  void _showOpinionForm() {
    String newOpinion = '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('شارك رأيك عن الحي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              onChanged: (value) => newOpinion = value,
              decoration: InputDecoration(
                hintText: 'اكتب رأيك هنا...',
                filled: true,
                fillColor: Colors.grey[100],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (newOpinion.trim().isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final userUrl = Uri.parse(
                      '$kDatabaseUrl/users/${user.uid}.json');
                  final userResponse = await http.get(userUrl);

                  String username = 'مستخدم';
                  if (userResponse.statusCode == 200) {
                    final userData = json.decode(userResponse.body);
                    if (userData != null && userData['username'] != null) {
                      username = userData['username'];
                    }
                  }

                  final url = Uri.parse(
                      '$kDatabaseUrl/communitys/${widget.neighborhoodId}.json');
                  await http.post(url,
                      body: json.encode({
                        'category': 'رأي',
                        'text': newOpinion.trim(),
                        'createdAt': DateTime.now().toIso8601String(),
                        'username': username,
                      }));

                  Navigator.pop(context);
                  fetchCommunityContent();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C8E97)),
              child:
                  const Text('إرسال', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNeighborhoodImage(String image) {
    if (image.startsWith('http')) {
      return Image.network(image,
          width: double.infinity, height: 260, fit: BoxFit.cover);
    } else if (image.startsWith('/')) {
      return Image.file(File(image),
          width: double.infinity, height: 260, fit: BoxFit.cover);
    } else if (image.length > 100) {
      return Image.memory(base64Decode(image),
          width: double.infinity, height: 260, fit: BoxFit.cover);
    } else {
      return Image.asset(image,
          width: double.infinity, height: 260, fit: BoxFit.cover);
    }
  }

  Widget _infoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
           Icon(icon, color: Color(0xFF2C8E97)),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C8E97))),
        ],
      ),
    );
  }

  Widget _buildImage(String imageString) {
    try {
      if (imageString.startsWith('http')) {
        return Image.network(
          imageString,
          width: 140,
          height: 100,
          fit: BoxFit.cover,
        );
      } else if (imageString.startsWith('/')) {
        return Image.file(
          File(imageString),
          width: 140,
          height: 100,
          fit: BoxFit.fitHeight,
        );
      } else {
        return Image.memory(
          base64Decode(imageString),
          width: 140,
          height: 100,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return Container(
        width: 140,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.white70),
      );
    }
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    List<String>? items,
    List<Map<String, dynamic>>? postItems,
    List<String>? imagePaths,
    String? actionLabel,
    VoidCallback? onActionTap,
    bool isImageScroll = false,
    Widget? customBody, // ← جسد مخصص للقسم (مثل الإعلانات)
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
             Icon(icon, color: Color(0xFF2C8E97)),
            const SizedBox(width: 6),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            if (actionLabel != null)
              GestureDetector(
                onTap: onActionTap ?? () {},
                child: Text(actionLabel,
                    style: const TextStyle(
                        color: Color(0xFF1976D2), fontSize: 14)),
              ),
          ]),
          const SizedBox(height: 10),

          // لو فيه جسم مخصص (زي الإعلانات)
          if (customBody != null) customBody

          // آراء السكان
          else if (title == 'آراء السكان' && postItems != null)
            ...postItems.map((opinion) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${opinion['username'] ?? 'مستخدم'}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF656663),
                            fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        opinion['text'] ?? '',
                        style: const TextStyle(
                            fontSize: 15, color: Color(0xFF1976D2)),
                      ),
                    ],
                  ),
                ))

          // الاحتياجات
          else if (title == 'الاحتياجات' && postItems != null)
            ...postItems.map((need) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        need['username'] ?? 'مستخدم',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF656663),
                            fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        need['text'] ?? '',
                        style: const TextStyle(
                            fontSize: 15, color: Color(0xFF1976D2)),
                      ),
                    ],
                  ),
                ))

          // المشاركات
          else if (postItems != null)
            ...postItems.map((post) => InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailsPage(
                        postId: post['id'],
                        text: post['text'],
                        createdAt: post['createdAt'] ?? '',
                        neighborhoodId: widget.neighborhoodId,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['username'] ?? 'مستخدم',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF656663),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post['text'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))

          // عناصر نصية عامة
          else if (items != null)
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(e,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w500)),
                )),

          // صور الحي سلايدر
          if (imagePaths != null && isImageScroll)
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final imageData = imageUrls[index];
                  final image = imageData['image'];
                  final username = imageData['username'] ?? 'مستخدم';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenGalleryPage(
                                  images: imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: _buildImage(image),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'BY : @$username',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF656663),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _eventsSection() {
    final hasEvents =
        widget.events != null && widget.events!.isNotEmpty;

    return _sectionCard(
      icon: Icons.event,
      title: 'الفعاليات القادمة',
      // لو فيه فعاليات نمررها كعناصر نصية؛ لو ما فيه نعرض رسالة افتراضية
      items: hasEvents ? widget.events : ['لا توجد فعاليات حالياً'],
    );
  }

  Widget _adsSection() {
    // جسم مخصص لعرض بطاقات الإعلانات داخل _sectionCard
    final adsBody = Column(
      children: ads.map((ad) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdDetailsPage(
                title: ad['title'],
                text: ad['text'],
                location: ad['location'],
                price: ad['price'],
                seller: ad['seller'],
                imagePath: ad['image'],
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ad['image'] != null
                      ? _buildImage(ad['image'])
                      : Container(
                          width: 140,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ad['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.teal)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(ad['location'], style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${ad['username'] ?? 'مستخدم'}',
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );

    return _sectionCard(
      icon: Icons.campaign_outlined,
      title: 'إعلانات السكان',
      actionLabel: 'إضافة إعلان', // ← زر بنفس ترتيب الأقسام الأخرى
      onActionTap: () => _navigateAndRefresh(
        AddAdPage(neighborhoodId: widget.neighborhoodId),
      ),
      customBody: adsBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBg = Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBg,

        // تفعيل الـdrawer (زر القائمة في الهيدر يفتحها)
        drawer: const CustomDrawer(),
        endDrawerEnableOpenDragGesture: false,

        body: Column(
          children: [
            // ===== الهيدر + صورة الحي =====
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                  child: _buildNeighborhoodImage(widget.neighborhoodImage),
                ),
                const Positioned(
                    top: 0, left: 0, right: 0, child: CustomHeaderAppBar(title: '')),
                Positioned(
                    bottom: 16,
                    right: 16,
                    child: _infoBox(Icons.location_on, widget.neighborhoodName)),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _showOpinionForm,
                    child: _infoBox(Icons.add, 'رأي جديد'),
                  ),
                ),
              ],
            ),

            // ===== وصف الحي =====
            if (widget.neighborhoodInfo != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.neighborhoodInfo!,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ),

            // ===== المحتوى =====
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchCommunityContent,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _sectionCard(
                      icon: Icons.campaign,
                      title: 'صوتك',
                      postItems: posts,
                      actionLabel: 'عرض المشاركات',
                      onActionTap: () => _navigateAndRefresh(
                          AddPostPage(neighborhoodId: widget.neighborhoodId)),
                    ),
                    _sectionCard(
                      icon: Icons.photo,
                      title: 'صور الحي',
                      imagePaths:
                          imageUrls.map((e) => e['image'] as String).toList(),
                      isImageScroll: true,
                      actionLabel: 'إضافة صورة',
                      onActionTap: () => _navigateAndRefresh(
                          AddPhotoPage(neighborhoodId: widget.neighborhoodId)),
                    ),
                    _sectionCard(
                      icon: Icons.push_pin,
                      title: 'الاحتياجات',
                      postItems: needs,
                      actionLabel: 'إضافة احتياج',
                      onActionTap: () => _navigateAndRefresh(
                          AddNeedPage(neighborhoodId: widget.neighborhoodId)),
                    ),

                    // ✅ الفعاليات القادمة (تظهر حتى لو فاضية برسالة افتراضية)
                    _eventsSection(),

                    // ✅ الإعلانات مع زر "إضافة إعلان" في الهيدر بنفس ترتيب الأزرار الأخرى
                    _adsSection(),

                    if (opinions.isNotEmpty)
                      _sectionCard(
                        icon: Icons.record_voice_over,
                        title: 'آراء السكان',
                        postItems: opinions,
                      ),

                    const SizedBox(height: 60),
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
