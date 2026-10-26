// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'custom_drawer.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Map<String, dynamic>> allReviews = [];
  bool isLoading = true;

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    fetchAllReviews();
  }

  Future<void> fetchAllReviews() async {
    final url = Uri.parse('$kDatabaseUrl/neighborhood.json');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      List<Map<String, dynamic>> reviewsList = [];

      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          var neighborhood = data[i];
          if (neighborhood != null &&
              neighborhood['name'] != null &&
              neighborhood['reviews'] != null) {
            final neighborhoodName = neighborhood['name'];
            final reviews = neighborhood['reviews'] as Map<String, dynamic>;

            reviews.forEach((reviewId, reviewData) {
              reviewsList.add({
                'neighborhoodId': i.toString(),
                'reviewId': reviewId,
                'neighborhoodName': neighborhoodName,
                'name': reviewData['name'],
                'comment': reviewData['comment'],
                'rating': reviewData['rating'],
                'img_uri': reviewData['img_uri'],
              });
            });
          }
        }
      }

      if (!mounted) return;
      setState(() {
        allReviews = reviewsList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب البيانات: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteReview(String neighborhoodId, String reviewId) async {
    final url = Uri.parse(
        '$kDatabaseUrl/neighborhood/$neighborhoodId/reviews/$reviewId.json');

    try {
      final response = await http.delete(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف التعليق بنجاح')),
        );
        setState(() {
          allReviews.removeWhere((r) => r['neighborhoodId'] == neighborhoodId && r['reviewId'] == reviewId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في حذف التعليق')),
        );
      }
    } catch (e) {
      debugPrint('حدث خطأ أثناء الحذف: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحذف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const CustomDrawer(),
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
                // ⛳️ الهيدر (مطابق لصفحات الأدمن)
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
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : allReviews.isEmpty
                          ? const Center(child: Text('لا توجد تعليقات'))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: allReviews.length,
                              itemBuilder: (context, index) {
                                final review = allReviews[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: _ReviewTile(
                                    name: (review['name'] ?? '').toString(),
                                    neighborhoodName: (review['neighborhoodName'] ?? '').toString(),
                                    comment: (review['comment'] ?? '').toString(),
                                    rating: _asDouble(review['rating']),
                                    imageUri: (review['img_uri'] ?? '').toString(),
                                    onDelete: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AlertDialog(
                                            title: const Text('تأكيد الحذف'),
                                            content: const Text('هل أنت متأكد من حذف هذا التعليق؟'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('إلغاء'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('حذف', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                      if (confirm == true) {
                                        await deleteReview(review['neighborhoodId'], review['reviewId']);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final String neighborhoodName;
  final String comment;
  final double rating;
  final String imageUri;
  final VoidCallback onDelete;

  const _ReviewTile({
    required this.name,
    required this.neighborhoodName,
    required this.comment,
    required this.rating,
    required this.imageUri,
    required this.onDelete,
  });

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    final ImageProvider avatarProvider = imageUri.startsWith('http')
        ? NetworkImage(imageUri)
        : (imageUri.isNotEmpty ? AssetImage(imageUri) as ImageProvider : const AssetImage('assets/images/default_profile.png'));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF6FBFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: kCardShadow, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصورة
                CircleAvatar(radius: 26, backgroundImage: avatarProvider),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                          _RatingStars(rating: rating),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ChipInfo(label: 'الحي', value: neighborhoodName),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
              ].reversed.toList(), // RTL ترتيب
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String label;
  final String value;
  const _ChipInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final int filled = rating.floor().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
            i < filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18,
          )),
    );
  }
}
