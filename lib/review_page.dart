// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ReviewPage extends StatefulWidget {
  final int neighborhoodId;
  const ReviewPage({super.key, required this.neighborhoodId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double averageRating = 0.0;
  int totalReviews = 0;
  User? currentUser;
  Map<String, dynamic>? userData;

  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0;

  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
    _fetchReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final url = Uri.parse(
        '$kDatabaseUrl/users/${currentUser!.uid}.json');

    final res = await http.get(url);
    if (!mounted) return;
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data != null) setState(() => userData = data);
    }
  }

  Future<void> _fetchReviews() async {
    final url = Uri.parse(
        '$kDatabaseUrl/neighborhood/${widget.neighborhoodId}/reviews.json');

    final res = await http.get(url);
    if (!mounted) return;
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data != null && data is Map) {
        final loaded = <Map<String, dynamic>>[];
        data.forEach((_, v) {
          loaded.add({
            'name': v['name'],
            'img_uri': v['img_uri'],
            'rating': (v['rating'] ?? 0) * 1.0,
            'comment': v['comment'] ?? '',
          });
        });
        setState(() {
          reviews = loaded;
          averageRating = reviews.isEmpty
              ? 0
              : reviews
                      .map((e) => (e['rating'] as num).toDouble())
                      .reduce((a, b) => a + b) /
                  reviews.length;
          totalReviews = reviews.length;
        });
      }
    }
  }

  Future<void> _submitReviewToFirebase({
    required int neighborhoodId,
    required String name,
    required String profileImage,
    required double rating,
    required String comment,
  }) async {
    final url = Uri.parse(
        '$kDatabaseUrl/neighborhood/$neighborhoodId/reviews.json');

    final res = await http.post(
      url,
      body: json.encode({
        'name': name,
        'img_uri': profileImage,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('فشل في رفع التقييم');
    }
  }

  void _submitReview() async {
    final name = (userData?['firstName'] ?? '').toString();
    final profileImage = (userData?['profileImage'] ?? '').toString();

    if (_commentController.text.trim().isEmpty ||
        _userRating <= 0 ||
        name.isEmpty ||
        profileImage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل التقييم والتعليق أولًا')),
      );
      return;
    }

    try {
      await _submitReviewToFirebase(
        neighborhoodId: widget.neighborhoodId,
        name: name,
        profileImage: profileImage,
        rating: _userRating,
        comment: _commentController.text.trim(),
      );

      setState(() {
        reviews.add({
          'name': name,
          'img_uri': profileImage,
          'rating': _userRating,
          'comment': _commentController.text.trim(),
        });
        _commentController.clear();
        _userRating = 0;
        averageRating = reviews
                .map((e) => (e['rating'] as num).toDouble())
                .reduce((a, b) => a + b) /
            reviews.length;
        totalReviews = reviews.length;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحفظ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

   
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _summaryCard(accent),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آراء الناس',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalReviews تقييم',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _card(),
              child: const Center(child: Text('لا توجد تعليقات بعد')),
            )
          else
            ...reviews.reversed.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _commentCard(r),
              ),
            ),

          const SizedBox(height: 20),

          if (userData != null) _reviewInput(accent) else _loginHint(),
        ],
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _summaryCard(Color accent) {
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: accent.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 26,
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text('متوسط', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ratingRow('الأمان'),
                _ratingRow('النظافة'),
                _ratingRow('الخدمات'),
                _ratingRow('الهدوء'),
                const SizedBox(height: 6),
                RatingBarIndicator(
                  rating: averageRating,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          const Icon(Icons.circle, size: 8, color: Colors.black26),
          const SizedBox(width: 3),
          const Icon(Icons.circle, size: 8, color: Colors.black26),
          const SizedBox(width: 3),
          const Icon(Icons.circle, size: 8, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _commentCard(Map<String, dynamic> review) {
    final img = (review['img_uri'] ?? '').toString();
    final name = (review['name'] ?? '').toString();
    final rating = (review['rating'] as num).toDouble();
    final comment = (review['comment'] ?? '').toString();

    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: img.startsWith('http')
                    ? NetworkImage(img)
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              RatingBarIndicator(
                rating: rating,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment),
        ],
      ),
    );
  }

  Widget _reviewInput(Color accent) {
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('أضف تقييمك',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (r) => _userRating = r,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'اكتب تعليقك هنا',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black.withOpacity(.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // زر إرسال بارتفاع كافي
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: _submitReview,
              icon: const Icon(Icons.send_outlined,
                  color: Colors.white, size: 18),
              label: const Text(
                'إرسال',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(293.31, 46),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(height: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginHint() {
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'يجب تسجيل الدخول لإضافة تعليق',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
