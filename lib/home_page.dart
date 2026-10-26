//coding : Lubna 
//Design in Flutter : Zainab Alaujami
import 'dart:async';
import 'config.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'details_home_page.dart' show DetailsHomePage;
import 'base_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCity = 'الدمام';

  List<Map<String, dynamic>> neighborhoods = [];
  List<Map<String, dynamic>> filteredNeighborhoods = [];

  late PageController _pageController;
  double currentPage = 0.0;

  Set<String> favoriteNeighborhoods = {};

  Timer? _searchTimer;
  String _query = '';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(() {
      setState(() => currentPage = _pageController.page ?? 0.0);
    });
    fetchNeighborhoods();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchNeighborhoods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
          "$kDatabaseUrl/neighborhood.json");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        final list = (raw is List) ? raw : <dynamic>[];

        neighborhoods = list
            .where((e) => e is Map && (e['city'] == selectedCity))
            .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map))
            .toList();

        _applyFilter();
      } else {
        _error = 'فشل في جلب البيانات (${response.statusCode})';
      }
    } catch (e) {
      _error = 'تعذر الاتصال: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCityChanged(String? city) {
    if (city == null) return;
    setState(() => selectedCity = city);
    fetchNeighborhoods();
  }

  void _applyFilter() {
    if (_query.isEmpty) {
      filteredNeighborhoods = List.of(neighborhoods);
    } else {
      filteredNeighborhoods = neighborhoods.where((n) {
        final text =
            '${n['name'] ?? ''} ${n['city'] ?? ''} ${n['description'] ?? ''}';
        return text.contains(_query);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      activeItem: 'home',
      currentIndex: 0,
      child: RefreshIndicator(
        onRefresh: fetchNeighborhoods,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _cityDropdown(context),
              _searchBox(),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('الأحياء المقترحة',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E9FB4))),
                ),
              ),

              if (_isLoading)
                _loadingStrip()
              else if (_error != null)
                _errorBlock()
              else if (filteredNeighborhoods.isEmpty)
                _emptyBlock()
              else
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: filteredNeighborhoods.length,
                    itemBuilder: (context, index) {
                      final scale = (0.98 - (currentPage - index).abs() * 0.2)
                          .clamp(0.9, 0.98);
                      final n = filteredNeighborhoods[index];
                      return AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: _neighborhoodCard(context, n),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('اكتشف الأحياء القريبة',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E9FB4))),
                ),
              ),
              const SizedBox(height: 12),

              _nearbyMiniMaps(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ===== اختيار المدينة كـ Dropdown =====
  Widget _cityDropdown(BuildContext context) {
    final cities = const ['الدمام', 'الخبر', 'القطيف'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCity,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF1E9FB4), 
            ),
            isExpanded: true,
            onChanged: _onCityChanged,
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(
                  city,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ===== صندوق البحث =====
  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        textDirection: TextDirection.rtl,
        onChanged: (v) {
          _query = v.trim();
          _searchTimer?.cancel();
          _searchTimer = Timer(const Duration(milliseconds: 300), _applyFilter);
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن حي...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _query = '';
                    _applyFilter();
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ===== بطاقة الحي =====
  Widget _neighborhoodCard(BuildContext context, Map<String, dynamic> n) {
    final name = '${n['name'] ?? ''} - ${n['city'] ?? ''}';
    final rating = n['over_allrate'] ?? n[' over_allrate'] ?? 0;
    final imageUrl = n['image_url'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsHomePage(neighborhood: n),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Hero(
              tag: 'nh_${n['name']}',
              child: Image.network(
                imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey.shade200),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(color: Colors.grey.shade200);
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 86,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(.55)],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(0, 1))
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('$rating',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.white70,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    final nName = n['name'];
                    if (nName == null) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final uid = user.uid;
                      final ref = FirebaseDatabase.instance
                          .ref("users/$uid/favorites")
                          .push();

                      await ref.set({
                        'title': nName,
                        'description': n['description'] ?? '',
                        'type': 'حي',
                      });

                      HapticFeedback.selectionClick();
                      setState(() {
                        favoriteNeighborhoods.add(nName);
                      });

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت الإضافة إلى المفضلة'),
                        ),
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يجب تسجيل الدخول أولاً'),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      favoriteNeighborhoods.contains(n['name'])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favoriteNeighborhoods.contains(n['name'])
                          ? Colors.red
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== مصغرات الأحياء =====
  Widget _nearbyMiniMaps() {
    final items = filteredNeighborhoods.take(8).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final n = items[i];
          final img = n['image_url'] ?? '';
          final title = n['name'] ?? '';
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailsHomePage(neighborhood: n)),
              );
            },
            child: Container(
              width: 150,
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
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.network(
                    img,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade200),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.0),
                          Colors.black.withOpacity(.45)
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: Icon(Icons.map, color: Colors.white70, size: 18),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _loadingStrip() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Container(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _errorBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        children: [
          Text(
            _error ?? 'حدث خطأ',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: fetchNeighborhoods,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          )
        ],
      ),
    );
  }

  Widget _emptyBlock() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Text(
        'لا توجد أحياء لعرضها حاليًا',
        textAlign: TextAlign.center,
      ),
    );
  }
}


