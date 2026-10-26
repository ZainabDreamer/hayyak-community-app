// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'add_edit_neighborhood_page.dart';
import 'custom_drawer.dart';

class NeighborhoodDetailsPage extends StatelessWidget {
  final Map<String, dynamic> neighborhood;

  const NeighborhoodDetailsPage({super.key, required this.neighborhood});

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    // تحويل آمن للخرائط
    final facilities = (neighborhood['facilities'] is Map)
        ? Map<String, dynamic>.from(neighborhood['facilities'] as Map)
        : <String, dynamic>{};

    final ratings = (neighborhood['ratings'] is Map)
        ? Map<String, dynamic>.from(neighborhood['ratings'] as Map)
        : <String, dynamic>{};

    final reviews = (neighborhood['reviews'] is Map)
        ? Map<String, dynamic>.from(neighborhood['reviews'] as Map)
        : <String, dynamic>{};

    final id = neighborhood['neighborhoodID'];

    final String name = (neighborhood['name'] ?? 'تفاصيل الحي').toString();
    final String imageUrl = (neighborhood['image_url'] ?? '').toString();
    final String city = (neighborhood['city'] ?? '').toString();
    final double areaKm2 = _asDouble(neighborhood['area_km2']);
    final double overall = _asDouble(neighborhood['over_allrate']);

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 840),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HeaderCard(
                              name: name,
                              imageUrl: imageUrl,
                              city: city,
                              overall: overall,
                            ),
                            const SizedBox(height: 12),

                            _SectionCard(children: [
                              _InfoRow(
                                title: 'الوصف',
                                value: (neighborhood['description'] ?? '').toString(),
                              ),
                              _InfoRow(title: 'المدينة', value: city.isEmpty ? '—' : city),
                              _InfoRow(
                                title: 'المساحة (كم²)',
                                value: areaKm2 == 0 ? '—' : areaKm2.toString(),
                              ),
                              _InfoRow(
                                title: 'التقييم الكلي',
                                value: overall == 0 ? '—' : overall.toStringAsFixed(2),
                              ),
                            ]),

                            if (facilities.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _SectionCard(children: [
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'المرافق',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...facilities.entries.map((entry) {
                                  final String key = entry.key.toString();
                                  final List<dynamic> rawList =
                                      (entry.value is List) ? entry.value as List : [];
                                  final List<String> values =
                                      rawList.map((e) => e.toString()).toList();
                                  return _InfoList(title: key, values: values);
                                }),
                              ]),
                            ],

                            if (ratings.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _SectionCard(children: [
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'التقييمات',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...ratings.entries.map(
                                  (e) => Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '• ${e.key}: ${e.value}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ]),
                            ],

                            if (reviews.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _SectionCard(children: [
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'آراء السكان',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...reviews.entries.map((e) {
                                  final dynamic val = e.value;
                                  final String rName =
                                      (val is Map && val['name'] != null) ? val['name'].toString() : '';
                                  final String rComment = (val is Map && val['comment'] != null)
                                      ? val['comment'].toString()
                                      : '';
                                  final String rRate = (val is Map && val['rating'] != null)
                                      ? val['rating'].toString()
                                      : '—';
                                  return ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    title: Text(
                                      rName,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    subtitle: Text(
                                      rComment,
                                      textAlign: TextAlign.right,
                                    ),
                                    trailing: Text('⭐ $rRate'),
                                  );
                                }),
                              ]),
                            ],

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddEditNeighborhoodPage(neighborhood: neighborhood),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C8E97),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('تعديل'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: const Text(
                                              'هل أنت متأكدة من حذف هذا الحي؟ لا يمكن التراجع.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('إلغاء')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('حذف')),
                                          ],
                                        ),
                                      ),
                                    );
                                    if (confirm != true) return;

                                    final url = Uri.parse(
                                        '$kDatabaseUrl/neighborhood/$id.json');
                                    final res = await http.delete(url);
                                    if (res.statusCode == 200) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('تم حذف الحي بنجاح')),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('فشل في حذف الحي')),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('حذف'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String city;
  final double overall;

  const _HeaderCard({
    required this.name,
    required this.imageUrl,
    required this.city,
    required this.overall,
  });

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF6FBFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: kCardShadow, blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F7),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 48, color: Colors.black54),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(text: city.isEmpty ? 'غير محدد' : city, icon: Icons.location_city),
                    _Chip(
                      text: overall == 0 ? '—' : overall.toStringAsFixed(2),
                      icon: Icons.star,
                      isEmphasis: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF6FBFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: kCardShadow, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // <-- يمين يمين
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            style: const TextStyle(fontSize: 15, color: Colors.black),
            children: [
              TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(text: value.isEmpty ? '—' : value),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoList extends StatelessWidget {
  final String title;
  final List<String> values;
  const _InfoList({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          ...values.map(
            (item) => Align(
              alignment: Alignment.centerRight,
              child: Text('- $item', textAlign: TextAlign.right),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isEmphasis;
  const _Chip({required this.text, required this.icon, this.isEmphasis = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isEmphasis ? const Color(0xFFE8F7F7) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
