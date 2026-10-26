// By : Maha 
// Design in Flutter : Zainab Alaujami
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'base_layout.dart';

class FavoriteItem {
  final String title;
  final String description;
  final String type;
  final String? key;

  FavoriteItem({
    required this.title,
    required this.description,
    required this.type,
    this.key,
  });
}

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = const ['الكل', 'تعليق', 'حي', 'اقتراح'];

  List<FavoriteItem> allFavorites = [];
  bool isLoading = true;
  StreamSubscription<DatabaseEvent>? _favSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _startListening();
  }

  void _startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        allFavorites = [];
      });
      return;
    }
    final uid = user.uid;
    final ref = FirebaseDatabase.instance.ref("users/$uid/favorites");

    _favSub = ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        setState(() {
          allFavorites = [];
          isLoading = false;
        });
        return;
      }
      final fetched = data.entries.map((e) {
        final value = (e.value as Map?) ?? {};
        return FavoriteItem(
          title: (value['title'] ?? '').toString(),
          description: (value['description'] ?? '').toString(),
          type: (value['type'] ?? '').toString(),
          key: e.key,
        );
      }).toList();

      setState(() {
        allFavorites = fetched;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _favSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _removeFromFavorites(String key) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    FirebaseDatabase.instance.ref("users/$uid/favorites/$key").remove();
  }

  List<FavoriteItem> _filtered(String filter) {
    if (filter == 'الكل') return allFavorites;
    return allFavorites.where((x) => x.type == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
     
      activeItem: 'favorites', 
      currentIndex: 3,         
      child: SafeArea(
        top: false, 
        child: DefaultTabController(
          length: _filters.length,
          child: Column(
            children: [
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
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
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: _filters.map((f) => Tab(text: f)).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // المحتوى
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: _filters.map((filter) {
                          final items = _filtered(filter);

                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                "لا توجد عناصر",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _FavCard(
                              item: items[i],
                              onRemove: (key) => _removeFromFavorites(key),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final FavoriteItem item;
  final void Function(String key) onRemove;

  const _FavCard({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان + حذف
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (item.key != null)
                  IconButton(
                    tooltip: 'إزالة',
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                    onPressed: () => onRemove(item.key!),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            if (item.description.isNotEmpty)
              Text(
                item.description,
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.right,
              ),

            const SizedBox(height: 12),

           
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.type.isEmpty ? 'غير مصنّف' : item.type,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
