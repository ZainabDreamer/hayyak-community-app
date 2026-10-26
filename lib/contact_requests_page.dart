// By : Areej (UI refreshed by Assistant per Zainab's request)
import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'custom_drawer.dart';

class ContactRequestsPage extends StatefulWidget {
  const ContactRequestsPage({super.key});

  @override
  State<ContactRequestsPage> createState() => _ContactRequestsPageState();
}

class _ContactRequestsPageState extends State<ContactRequestsPage> {
  List<Map<String, dynamic>> allRequests = [];
  String selectedFilter = 'الكل';
  String? selectedNeighborhood;

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final url = Uri.parse('$kDatabaseUrl/contacts.json');
    final response = await http.get(url);

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data is Map<String, dynamic>) {
        final List<Map<String, dynamic>> loadedRequests = [];
        data.forEach((key, value) {
          loadedRequests.add({...value, 'id': key});
        });
        setState(() {
          allRequests = loadedRequests;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب البيانات من السيرفر')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredRequests {
    List<Map<String, dynamic>> filtered = [...allRequests];

    if (selectedFilter == 'غير المعالجة') {
      filtered = filtered.where((req) => req['isHandled'] != true).toList();
    } else if (selectedFilter == 'المعالجة') {
      filtered = filtered.where((req) => req['isHandled'] == true).toList();
    }

    if (selectedNeighborhood != null && selectedNeighborhood!.isNotEmpty) {
      filtered = filtered
          .where((req) => req['neighborhood']?.toString().trim() == selectedNeighborhood)
          .toList();
    }

    return filtered;
  }

  Future<void> _markAsHandled(String id) async {
    final url = Uri.parse('$kDatabaseUrl/contacts/$id.json');
    await http.patch(url, body: json.encode({'isHandled': true}));
    fetchRequests();
  }

  Future<void> _deleteRequest(String id) async {
    final url = Uri.parse('$kDatabaseUrl/contacts/$id.json');
    await http.delete(url);
    fetchRequests();
  }

  void _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=رد على الشكوى&body=مرحبًا،'),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح تطبيق البريد')),
      );
    }
  }

  void _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> neighborhoods = allRequests
        .map((req) => req['neighborhood']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

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
                // ⛳️ الهيدر (مطابق لهوية صفحات الأدمن)
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

                // فلاتر الحالة
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['الكل', 'غير المعالجة', 'المعالجة'].map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2C8E97),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          onSelected: (_) {
                            setState(() => selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // فلترة حسب الحي
                if (neighborhoods.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: DropdownButtonFormField<String>(
                      value: selectedNeighborhood,
                      hint: const Text('فلترة حسب الحي'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF2C8E97), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: neighborhoods
                          .map((neigh) => DropdownMenuItem(value: neigh, child: Align(alignment: Alignment.centerRight, child: Text(neigh))))
                          .toList(),
                      onChanged: (value) => setState(() => selectedNeighborhood = value),
                    ),
                  ),

                // القائمة
                Expanded(
                  child: filteredRequests.isEmpty
                      ? const Center(child: Text('لا توجد طلبات'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _RequestTile(
                                title: (request['title'] ?? '').toString(),
                                name: (request['name'] ?? '').toString(),
                                email: (request['email'] ?? '').toString(),
                                phone: (request['phone'] ?? '').toString(),
                                neighborhood: (request['neighborhood'] ?? '').toString(),
                                reason: (request['reason'] ?? '').toString(),
                                isHandled: request['isHandled'] == true,
                                onMarkHandled: request['isHandled'] == true ? null : () => _markAsHandled(request['id']),
                                onDelete: () => _deleteRequest(request['id']),
                                onEmailTap: _launchEmail,
                                onPhoneTap: _launchPhone,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String title;
  final String name;
  final String email;
  final String phone;
  final String neighborhood;
  final String reason;
  final bool isHandled;
  final VoidCallback? onMarkHandled;
  final VoidCallback onDelete;
  final Function(String) onEmailTap;
  final Function(String) onPhoneTap;

  const _RequestTile({
    required this.title,
    required this.name,
    required this.email,
    required this.phone,
    required this.neighborhood,
    required this.reason,
    required this.isHandled,
    required this.onMarkHandled,
    required this.onDelete,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

  static const Color kCardShadow = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // العنوان
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                // معلومات أساسية
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                    _ChipInfo(label: '👤 الاسم', value: name),
                    GestureDetector(
                      onTap: () => onEmailTap(email),
                      child: _ChipInfo(label: '📧 البريد', value: email, isLink: true),
                    ),
                    GestureDetector(
                      onTap: () => onPhoneTap(phone),
                      child: _ChipInfo(label: '📞 الجوال', value: phone, isLink: true),
                    ),
                    _ChipInfo(label: '🏘️ الحي', value: neighborhood),
                  ],
                ),
                const SizedBox(height: 10),
                // سبب التواصل
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💬 سبب التواصل:\n$reason',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isHandled ? null : onMarkHandled,
                      icon: const Icon(Icons.check),
                      label: Text(isHandled ? 'تمت المعالجة' : 'تحديد كمُعالجة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHandled ? Colors.green : const Color(0xFF2C8E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('حذف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
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
  final bool isLink;
  const _ChipInfo({required this.label, required this.value, this.isLink = false});

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
        style: TextStyle(fontSize: 12, color: isLink ? Colors.blue : Colors.black87, decoration: isLink ? TextDecoration.underline : TextDecoration.none),
      ),
    );
  }
}

