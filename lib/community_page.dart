// By : Zainab
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'neighborhood_page.dart';
import 'package:flutter/cupertino.dart';
import 'base_layout.dart'; 
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Map<String, dynamic>> joinedNeighborhoodsData = [];

  @override
  void initState() {
    super.initState();
    fetchJoinedNeighborhoods();
  }

  Future<void> fetchJoinedNeighborhoods() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final joinedUrl = Uri.parse(
      '$kDatabaseUrl/users/$uid/joinedNeighborhoods.json',
    );

    final joinedRes = await http.get(joinedUrl);
    if (joinedRes.statusCode != 200) return;

    final joinedDecoded = json.decode(joinedRes.body);

   
    Map<String, dynamic> joinedMap = {};

    if (joinedDecoded is Map<String, dynamic>) {
      joinedMap = joinedDecoded;
    } else if (joinedDecoded is List) {
      for (int i = 0; i < joinedDecoded.length; i++) {
        if (joinedDecoded[i] == true) {
          joinedMap[i.toString()] = true;
        }
      }
    } else {
      
      return;
    }

    //  كل الأحياء
    final allNeighborhoodsUrl = Uri.parse(
      '$kDatabaseUrl/neighborhood.json',
    );
    final allRes = await http.get(allNeighborhoodsUrl);
    if (allRes.statusCode != 200) return;

    final List<dynamic> allListRaw = json.decode(allRes.body);
    final List<Map<String, dynamic>> allList =
        allListRaw.cast<Map<String, dynamic>>();

    // المفلترة
    final filtered = allList.where((n) {
      final id = n['neighborhoodID'].toString();
      return joinedMap.containsKey(id) && joinedMap[id] == true;
    }).toList();

    setState(() {
      joinedNeighborhoodsData = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF338C9A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BaseLayout(
       
        activeItem: 'community', 
        currentIndex: 1,
        child: Column(
          children: [
            // ====== الهيدر مع البنر ======
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 240, 
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.asset(
                      'assets/images/header.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFFE8F7F7), Color(0xFFDFF5F4)],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
               
              ],
            ),

          
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups, color: primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'مجتمع حيّك',
                      style: TextStyle(
                        color: primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ====== القائمة / الحالة ======
            Expanded(
              child: joinedNeighborhoodsData.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: joinedNeighborhoodsData.length,
                      itemBuilder: (context, index) {
                        final n = joinedNeighborhoodsData[index];
                        return _buildNeighborhoodCard(
                          context,
                          n['image_url'] ?? 'assets/default.jpg',
                          '${n['name']} - ${n['city']}',
                          '٣ كلم',
                          '٢٠ عضو',
                          '٣٠ مشاركة',
                          n['description'] ?? '',
                          n['over_allrate']?.toString() ?? '4.0',
                          NeighborhoodPage(
                            neighborhoodId: n['neighborhoodID'].toString(),
                            neighborhoodName: n['name'],
                            neighborhoodImage: n['image_url'] ?? '',
                            neighborhoodInfo: n['description'],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    const primary = Color(0xFF338C9A);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.groups_2_outlined, color: primary, size: 56),
            SizedBox(height: 12),
            Text(
              'لا توجد أحياء منضمة بعد',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'انضم من صفحة تفاصيل الحي لظهوره هنا.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة الحي — تصميم فقط (المنطق كما هو)
  static Widget _buildNeighborhoodCard(
    BuildContext context,
    String image,
    String name,
    String distance,
    String members,
    String posts,
    String description,
    String rating,
    Widget detailPage,
  ) {
    const primary = Color(0xFF338C9A);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => detailPage),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الحي
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 96,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 96, height: 76, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 12),

            // معلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$distance | $members | $posts',
                    style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '“$description”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.home, size: 16, color: primary),
                      SizedBox(width: 6),
                      Icon(Icons.local_hospital, size: 16, color: primary),
                      SizedBox(width: 6),
                      Icon(Icons.park, size: 16, color: primary),
                      Spacer(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
