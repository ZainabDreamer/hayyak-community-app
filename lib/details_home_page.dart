// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'base_layout.dart';
import 'detail_page.dart';
import 'review_page.dart';
import 'map_page.dart';
import 'join_community_page.dart';

class DetailsHomePage extends StatefulWidget {
  final Map<String, dynamic> neighborhood;
  const DetailsHomePage({super.key, required this.neighborhood});

  @override
  State<DetailsHomePage> createState() => _DetailsHomePageState();
}

class _DetailsHomePageState extends State<DetailsHomePage> {
  int selectedTab = 0;

  List<Widget> _tabs(Map<String, dynamic> n) => [
        DetailPage(neighborhood: n),
        ReviewPage(neighborhoodId: n['neighborhoodID']),
        const MapPage(),
        JoinCommunityPage(neighborhoodId: n['neighborhoodID']),
      ];

  final tabLabels = const ['تفاصيل', 'المراجعات', 'الخريطة', 'المجتمع'];

  @override
  Widget build(BuildContext context) {
    final n = widget.neighborhood;
    final name = n['name'] ?? '';
    final imageUrl = n['image_url'] ?? '';
    final accent = Theme.of(context).colorScheme.primary;

   
    return BaseLayout(
      activeItem: 'home',
      currentIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // صورة الغلاف
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Hero(
              tag: 'nh_${n['name']}',
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey.shade300),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // العنوان
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // تبويبات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabLabels.length, (i) {
                final selected = selectedTab == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Text(
                        tabLabels[i],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected ? accent : Colors.black,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(top: 6),
                        height: 3,
                        width: selected ? 36 : 0,
                        color: accent,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // محتوى التبويب
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _tabs(n)[selectedTab],
            ),
          ),
        ],
      ),
    );
  }
}
