// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'package:flutter/material.dart';
import 'config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_user_page.dart';
import 'edit_user_page.dart';
import 'custom_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
        '$kDatabaseUrl/users.json');
    final response = await http.get(url);

    if (!mounted) return;

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> loadedUsers = [];

      data.forEach((key, value) {
        loadedUsers.add({
          'id': key,
          'firstName': value['firstName'] ?? '',
          'lastName': value['lastName'] ?? '',
          'username': value['username'] ?? '',
          'email': value['email'] ?? '',
          'phone': value['phone'] ?? '',
          'city': value['city'] ?? '',
          'neighborhood': value['neighborhood'] ?? '',
        });
      });

      setState(() {
        allUsers = loadedUsers;
        filteredUsers = loadedUsers;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void filterUsers(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = allUsers.where((user) {
      final fullName = '${user['firstName']} ${user['lastName']}'.toLowerCase();
      final username = (user['username'] ?? '').toLowerCase();
      return fullName.contains(lowerQuery) || username.contains(lowerQuery);
    }).toList();

    setState(() {
      filteredUsers = filtered;
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
                // ⛳️ الهيدر (نفس نمط صفحة الأدمن)
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
                      onChanged: filterUsers,
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم المستخدم أو الاسم',
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

                // القائمة
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final fullName = "${user['firstName']} ${user['lastName']}";

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: _UserTile(
                                fullName: fullName,
                                username: user['username'],
                                email: user['email'],
                                phone: user['phone'],
                                city: user['city'],
                                neighborhood: user['neighborhood'],
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUserPage(user: user),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  // TODO: delete logic (محفوظ كما هو بدون تغيير المنطق الحالي)
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
              MaterialPageRoute(builder: (context) => const AddUserPage()),
            );
          },
          child: const Icon(Icons.add),
          
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String city;
  final String neighborhood;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTile({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.city,
    required this.neighborhood,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onEdit, // فتح التحرير عند الضغط على الكرت كله
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // أيقونة بديلة لصورة المستخدم مستقبلاً
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          runSpacing: 2,
                          spacing: 8,
                          children: [
                            _ChipInfo(label: 'اسم المستخدم', value: username),
                            _ChipInfo(label: 'البريد', value: email),
                            _ChipInfo(label: 'الجوال', value: phone),
                            _ChipInfo(label: 'المدينة', value: city),
                            _ChipInfo(label: 'الحي', value: neighborhood),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
                    ],
                  )
                ],
              ),
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

  const _ChipInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}

