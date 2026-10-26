// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> neighborhood;
  const DetailPage({super.key, required this.neighborhood});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? facilityDetails;
  bool isLoading = false;

  final Color accent = const Color(0xFF338C9A); 

  Future<void> fetchFacilityDetails(String facilityTypeArabic) async {
    setState(() {
      isLoading = true;
      facilityDetails = null;
    });

    final neighborhoodId = widget.neighborhood['neighborhoodID'];

    try {
      final url = Uri.parse(
        '$kDatabaseUrl/neighborhood/$neighborhoodId/facilities/$facilityTypeArabic.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data is List) {
            facilityDetails = '• ' + data.join('\n• ');
          } else if (data is String) {
            facilityDetails = data;
          } else {
            facilityDetails = 'لا توجد معلومات متاحة.';
          }
        });
      } else {
        setState(() => facilityDetails = 'حدث خطأ أثناء جلب البيانات.');
      }
    } catch (_) {
      setState(() => facilityDetails = 'تعذر الاتصال بالخادم.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String description =
        widget.neighborhood['description'] ?? 'لا يوجد وصف متاح حالياً';
        
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            InfoCard(
              title: 'الوصف',
              content: description,
              centerTitle: true,
              titleColor: accent,
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'المرافق',
              centerTitle: true,
              titleColor: accent,
              child: Column(
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      IconTile(icon: Icons.local_hospital, color: accent,
                          onTap: () => fetchFacilityDetails("المستشفيات")),
                      IconTile(icon: Icons.mosque, color: accent,
                          onTap: () => fetchFacilityDetails("المساجد")),
                      IconTile(icon: Icons.school, color: accent,
                          onTap: () => fetchFacilityDetails("المدارس")),
                      IconTile(icon: Icons.park, color: accent,
                          onTap: () => fetchFacilityDetails("الحدائق")),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      IconTile(icon: Icons.local_gas_station, color: accent,
                          onTap: () => fetchFacilityDetails("محطات الغاز")),
                      IconTile(icon: Icons.shopping_cart, color: accent,
                          onTap: () => fetchFacilityDetails("محلات التسوق")),
                      IconTile(icon: Icons.restaurant, color: accent,
                          onTap: () => fetchFacilityDetails("مطاعم")),
                      IconTile(icon: Icons.fitness_center, color: accent,
                          onTap: () => fetchFacilityDetails("نادي رياضي")),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (isLoading)
                    CircularProgressIndicator(color: accent)
                  else if (facilityDetails != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        facilityDetails!,
                        style: const TextStyle(fontSize: 19),
                      ),
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

class InfoCard extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? child;
  final bool centerTitle;
  final Color titleColor;

  const InfoCard({
    super.key,
    required this.title,
    this.content,
    this.child,
    this.centerTitle = false,
    this.titleColor = const Color(0xFF338C9A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          if (content != null)
            Text(content!, style: const TextStyle(fontSize: 20)),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class IconTile extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const IconTile({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF338C9A),
  });

  @override
  State<IconTile> createState() => _IconTileState();
}

class _IconTileState extends State<IconTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_hovering ? .18 : .10),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: _hovering ? 10 : 6,
                offset: Offset(0, _hovering ? 6 : 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: _hovering ? 30 : 28,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
