// By: Areej (UI refreshed by Assistant per Zainab's request)
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_drawer.dart';

class AddEditNeighborhoodPage extends StatefulWidget {
  final Map<String, dynamic>? neighborhood;

  const AddEditNeighborhoodPage({super.key, this.neighborhood});

  @override
  State<AddEditNeighborhoodPage> createState() => _AddEditNeighborhoodPageState();
}

class _AddEditNeighborhoodPageState extends State<AddEditNeighborhoodPage> {
  final nameController = TextEditingController();
  final imageUrlController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final rateController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<TextEditingController> gardensControllers = [];
  final List<TextEditingController> schoolsControllers = [];
  final List<TextEditingController> mosquesControllers = [];

  static const Color kCardShadow = Color(0x1F000000);

  @override
  void initState() {
    super.initState();
    final n = widget.neighborhood;
    if (n != null) {
      nameController.text = n['name'] ?? '';
      imageUrlController.text = n['image_url'] ?? '';
      cityController.text = n['city'] ?? '';
      areaController.text = '${n['area_km2'] ?? ''}';
      rateController.text = '${n['over_allrate'] ?? ''}';
      descriptionController.text = n['description'] ?? '';

      for (var g in (n['facilities']?['الحدائق'] ?? [])) {
        gardensControllers.add(TextEditingController(text: g));
      }
      for (var s in (n['facilities']?['المدارس'] ?? [])) {
        schoolsControllers.add(TextEditingController(text: s));
      }
      for (var m in (n['facilities']?['المساجد'] ?? [])) {
        mosquesControllers.add(TextEditingController(text: m));
      }
    } else {
      gardensControllers.add(TextEditingController());
      schoolsControllers.add(TextEditingController());
      mosquesControllers.add(TextEditingController());
    }
  }

  Future<void> saveNeighborhood() async {
    final isEditing = widget.neighborhood != null;

    final data = {
      'name': nameController.text,
      'image_url': imageUrlController.text,
      'city': cityController.text,
      'area_km2': double.tryParse(areaController.text) ?? 0.0,
      'over_allrate': double.tryParse(rateController.text) ?? 0.0,
      'description': descriptionController.text,
      'facilities': {
        'الحدائق': gardensControllers.map((c) => c.text).where((e) => e.isNotEmpty).toList(),
        'المدارس': schoolsControllers.map((c) => c.text).where((e) => e.isNotEmpty).toList(),
        'المساجد': mosquesControllers.map((c) => c.text).where((e) => e.isNotEmpty).toList(),
      },
      'ratings': {},
      'reviews': {},
    };

    try {
      const baseUrl = kDatabaseUrl;

      if (isEditing) {
        final id = widget.neighborhood!['neighborhoodID'];
        final updateUrl = Uri.parse('$baseUrl/neighborhood/$id.json');
        await http.patch(updateUrl, body: json.encode(data));
      } else {
        final getUrl = Uri.parse('$baseUrl/neighborhood.json');
        final getResponse = await http.get(getUrl);
        int newID = 0;

        if (getResponse.statusCode == 200 && getResponse.body.isNotEmpty) {
          final existing = json.decode(getResponse.body);
          if (existing is List) {
            newID = existing.length;
          } else if (existing is Map) {
            newID = existing.keys.length;
          }
        }

        final newNeighborhood = {...data, 'neighborhoodID': newID};
        final addUrl = Uri.parse('$baseUrl/neighborhood/$newID.json');
        await http.put(addUrl, body: json.encode(newNeighborhood));

        final communityUrl = Uri.parse('$baseUrl/communitys/$newID.json');
        await http.put(communityUrl, body: json.encode({
          "createdAt": DateTime.now().toIso8601String(),
          "posts": {},
          "ads": {},
          "needs": {},
          "photos": {},
        }));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحفظ بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ في الحفظ: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في الحفظ')),
      );
    }
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 840),
                        child: _buildFormCard(context),
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

  Widget _buildFormCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
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
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //const Icon(Icons.home_work_outlined, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    widget.neighborhood == null ? ' ' : ' ',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // حقول أساسية (Grid RTL)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 560;
                  final colW = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _LabeledField(
                        label: 'اسم الحي',
                        width: colW,
                        child: _buildTextField(nameController, hint: 'اكتب اسم الحي', icon: Icons.home_outlined),
                      ),
                      _LabeledField(
                        label: 'رابط الصورة',
                        width: colW,
                        child: _buildTextField(imageUrlController, hint: 'https://...', icon: Icons.link),
                      ),
                      _LabeledField(
                        label: 'المدينة',
                        width: colW,
                        child: _buildTextField(cityController, hint: 'اسم المدينة', icon: Icons.location_city),
                      ),
                      _LabeledField(
                        label: 'المساحة (كم²)',
                        width: colW,
                        child: _buildTextField(areaController, hint: '0.0', keyboardType: TextInputType.number, icon: Icons.square_foot),
                      ),
                      _LabeledField(
                        label: 'التقييم العام',
                        width: colW,
                        child: _buildTextField(rateController, hint: '0.0', keyboardType: TextInputType.number, icon: Icons.star_rate_outlined),
                      ),
                      _LabeledField(
                        label: 'الوصف',
                        width: colW,
                        child: _buildTextField(descriptionController, hint: 'نبذة عن الحي', icon: Icons.description_outlined, maxLines: 3),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // الأقسام الديناميكية (الحدائق/المدارس/المساجد)
              _FacilitiesSection(title: 'الحدائق', controllers: gardensControllers, onChanged: () => setState(() {})),
              _FacilitiesSection(title: 'المدارس', controllers: schoolsControllers, onChanged: () => setState(() {})),
              _FacilitiesSection(title: 'المساجد', controllers: mosquesControllers, onChanged: () => setState(() {})),

              const SizedBox(height: 22),

              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C8E97),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: saveNeighborhood,
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text('حفظ', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
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
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final double width;

  const _LabeledField({
    required this.label,
    required this.child,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C8E97),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _FacilitiesSection extends StatelessWidget {
  final String title;
  final List<TextEditingController> controllers;
  final VoidCallback onChanged;

  static const Color kCardShadow = Color(0x1F000000);

  const _FacilitiesSection({
    required this.title,
    required this.controllers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF2C8E97),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: '$title ${index + 1}',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      controllers.removeAt(index);
                      onChanged();
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: kCardShadow, blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.delete_outline, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2C8E97)),
              foregroundColor: const Color(0xFF2C8E97),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controllers.add(TextEditingController());
              onChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة عنصر'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
