// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JoinCommunityPage extends StatelessWidget {
  final int neighborhoodId;

  const JoinCommunityPage({super.key, required this.neighborhoodId});

  Future<void> joinCommunity(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول أولاً")),
      );
      return;
    }

    final uid = user.uid;

    try {
      
      final joinedUrl = Uri.parse(
        '$kDatabaseUrl/users/$uid/joinedNeighborhoods/$neighborhoodId.json',
      );
      await http.put(joinedUrl, body: json.encode(true));

      //  جلب بيانات المستخدم
      final userDataUrl = Uri.parse(
        '$kDatabaseUrl/users/$uid.json',
      );
      final userRes = await http.get(userDataUrl);
      if (userRes.statusCode != 200) {
        throw Exception("فشل في جلب بيانات المستخدم");
      }
      final userData = json.decode(userRes.body);

      //  إضافة المستخدم لقائمة أعضاء المجتمع
      final memberUrl = Uri.parse(
        '$kDatabaseUrl/communitys/$neighborhoodId/members/$uid.json',
      );
      await http.put(memberUrl, body: json.encode({
        "firstName": userData['firstName'],
        "lastName": userData['lastName'],
        "email": userData['email'],
        "username": userData['username'],
        "img_uri": userData['profileImage'],
        "role": userData['role'],
      }));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم الانضمام إلى المجتمع بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ حدث خطأ: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // صورة وكارد أنيق
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              'https://i.ibb.co/NdZ82jPz/1.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),

          // عنوان
          const Text(
            'المجتمع يبدأ بك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          // وصف
          const Text(
            'ستتمكن من متابعة أخبار الحي والمشاركة مع الجيران في تطوير المجتمع.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),

         
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () => joinCommunity(context),
              icon: const Icon(Icons.groups_2_outlined, color: Colors.white, size: 18),
              label: const Text(
                'انضم الآن',
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
}
