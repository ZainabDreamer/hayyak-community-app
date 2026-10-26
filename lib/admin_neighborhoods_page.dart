// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'package:flutter/material.dart';
import 'config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'neighborhood_details_page.dart';
import 'add_edit_neighborhood_page.dart';
import 'custom_drawer.dart';

class NeighborhoodsPage extends StatefulWidget {
  const NeighborhoodsPage({super.key});

  @override
  State<NeighborhoodsPage> createState() => _NeighborhoodsPageState();
}

class _NeighborhoodsPageState extends State<NeighborhoodsPage> {
  List<Map<String, dynamic>> neighborhoods = [];
  List<Map<String, dynamic>> filteredNeighborhoods = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSyncing = false;

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    fetchNeighborhoods();
  }

  Future<void> fetchNeighborhoods() async {
    final url = Uri.parse(
        '$kDatabaseUrl/neighborhood.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> loaded = [];

        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          if (item != null) {
            loaded.add({
              'neighborhoodID': item['neighborhoodID'] ?? i,
              'name': item['name'] ?? 'اسم غير معروف',
              'image_url': item['image_url'] ?? '',
              'description': item['description'] ?? '',
              'city': item['city'] ?? '',
              'facilities': item['facilities'] ?? {},
              'ratings': item['ratings'] ?? {},
              'reviews': item['reviews'] ?? {},
              'over_allrate': item['over_allrate'] ?? item[' over_allrate'] ?? 0.0,
            });
          }
        }

        setState(() {
          neighborhoods = loaded;
          filteredNeighborhoods = loaded;
          isLoading = false;
        });
      } catch (e) {
        debugPrint('خطأ في تحليل البيانات: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      debugPrint("فشل في تحميل الأحياء: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> syncAllCommunities() async {
    setState(() => isSyncing = true);
    final baseUrl = kDatabaseUrl;

    try {
      final response = await http.get(Uri.parse('$baseUrl/neighborhood.json'));
      final data = json.decode(response.body);

      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null) {
            final communityRef = Uri.parse('$baseUrl/communitys/$i.json');
            final communityExists = await http.get(communityRef);

            if (communityExists.body == 'null') {
              await http.put(communityRef, body: json.encode({
                "createdAt": DateTime.now().toIso8601String(),
                "posts": {},
                "ads": {},
                "needs": {},
                "photos": {},
              }));
            }
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم إنشاء المجتمعات بنجاح")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ تعذر قراءة بيانات الأحياء")),
        );
      }
    } catch (e) {
      debugPrint('خطأ في المزامنة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ حدث خطأ أثناء الاتصال")),
      );
    }

    setState(() => isSyncing = false);
  }

  void filterNeighborhoods(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = neighborhoods.where((neighborhood) {
      final name = neighborhood['name'].toString().toLowerCase();
      return name.contains(lowerQuery);
    }).toList();

    setState(() {
      filteredNeighborhoods = filtered;
    });
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
                // ⛳️ الهيدر (نفس نمط صفحات الأدمن)
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

                // شريط البحث
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: kCardShadow, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterNeighborhoods,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم الحي',
                        hintStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: const Icon(Icons.search, color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // زر المزامنة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSyncing ? null : syncAllCommunities,
                      icon: isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: const Text("مزامنة المجتمعات مع الأحياء"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C8E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),

                // القائمة
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredNeighborhoods.isEmpty
                          ? const Center(child: Text("لا توجد أحياء متاحة"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 88),
                              itemCount: filteredNeighborhoods.length,
                              itemBuilder: (context, index) {
                                final neighborhood = filteredNeighborhoods[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: _NeighborhoodTile(
                                    name: neighborhood['name'],
                                    imageUrl: neighborhood['image_url'],
                                    city: neighborhood['city'],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NeighborhoodDetailsPage(
                                            neighborhood: neighborhood,
                                          ),
                                        ),
                                      );
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddEditNeighborhoodPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _NeighborhoodTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String city;
  final VoidCallback onTap;

  const _NeighborhoodTile({
    required this.name,
    required this.imageUrl,
    required this.city,
    required this.onTap,
  });

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover)
                      : Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFE8F7F7),
                          child: const Icon(Icons.image_not_supported, color: Colors.black54),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              city.isNotEmpty ? city : '—',
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                ),
              ].reversed.toList(), // RTL ترتيب
            ),
          ),
        ),
      ),
    );
  }
}
