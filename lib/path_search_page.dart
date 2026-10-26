// By : Afnan
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'base_layout.dart';
import 'pick_location_page.dart';
import 'safe_route_result_page.dart';

class PathSearchPage extends StatefulWidget {
  const PathSearchPage({super.key});

  @override
  State<PathSearchPage> createState() => _PathSearchPageState();
}

class _PathSearchPageState extends State<PathSearchPage> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  LatLng? selectedFrom;
  LatLng? selectedTo;

  // 'walk' | 'bike' | 'wheelchair'
  String? selectedPathType;

  // مقدار نزول زر البحث (غيّره حسب ذوقك)
  static const double kButtonTopGap = 60;

  final List<String> recentPlaces = const [
    'ممشى الراكة',
    'حديقة الشاطئ',
    'مركز النور الصحي',
    'ممشى السلام',
    'مركز الأمير سلطان',
    'حديقة الملك فهد',
  ];

  Future<void> _selectFromOnMap() async {
    final selected = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => const PickLocationPage(title: 'اختر موقع الانطلاق'),
      ),
    );
    if (selected != null) {
      setState(() {
        selectedFrom = selected;
        if (fromController.text.trim().isEmpty) {
          fromController.text =
              '${selected.latitude.toStringAsFixed(5)}, ${selected.longitude.toStringAsFixed(5)}';
        }
      });
    }
  }

  Future<void> _selectToOnMap() async {
    final selected = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => const PickLocationPage(title: 'اختر موقع الوصول'),
      ),
    );
    if (selected != null) {
      setState(() {
        selectedTo = selected;
        if (toController.text.trim().isEmpty) {
          toController.text =
              '${selected.latitude.toStringAsFixed(5)}, ${selected.longitude.toStringAsFixed(5)}';
        }
      });
    }
  }

  LatLng? _tryParseLatLng(String input) {
    final txt = input.trim();
    final comma = txt.split(',');
    final space = txt.split(RegExp(r'\s+'));
    List<String> parts;
    if (comma.length == 2) {
      parts = [comma[0].trim(), comma[1].trim()];
    } else if (space.length == 2) {
      parts = [space[0].trim(), space[1].trim()];
    } else {
      return null;
    }
    try {
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      if (lat.abs() <= 90 && lng.abs() <= 180) {
        return LatLng(lat, lng);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensurePointForField({
    required TextEditingController controller,
    required bool isFrom,
  }) async {
    // لو المستخدم كتب إحداثيات صحيحة نستخدمها مباشرة
    final parsed = _tryParseLatLng(controller.text);
    if (parsed != null) {
      setState(() {
        if (isFrom) {
          selectedFrom = parsed;
        } else {
          selectedTo = parsed;
        }
      });
      return;
    }

    // غير كذا: نفتح الخريطة للاختيار
    final picked = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => PickLocationPage(
          title: isFrom ? 'حدد موقع الانطلاق' : 'حدد موقع الوصول',
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          selectedFrom = picked;
          if (controller.text.trim().isEmpty) {
            controller.text =
                '${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}';
          }
        } else {
          selectedTo = picked;
          if (controller.text.trim().isEmpty) {
            controller.text =
                '${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}';
          }
        }
      });
    }
  }

  Future<void> _searchPath() async {
    if (fromController.text.isEmpty || toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال نقطتي الانطلاق والوصول')),
      );
      return;
    }
    if (selectedPathType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع المسار')),
      );
      return;
    }

    // تأكيد وجود نقطتي البداية والنهاية
    if (selectedFrom == null) {
      await _ensurePointForField(controller: fromController, isFrom: true);
    }
    if (selectedTo == null) {
      await _ensurePointForField(controller: toController, isFrom: false);
    }

    if (selectedFrom == null || selectedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لازم تحدد الموقعين من الخريطة أو بالإحداثيات')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SafeRouteResultPage(
          from: selectedFrom!,
          to: selectedTo!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BaseLayout(
        activeItem: 'routes',
        currentIndex: 1,
        child: SafeArea(
          top: false,
          child: ListView(
            // رفع المحتوى لفوق وتقليل الفراغ
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            children: [
              // حقول "من" و"إلى" — بدون كارد أبيض خارجي
              _buildInputField(
                label: 'من',
                controller: fromController,
                onMapTap: _selectFromOnMap,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                label: 'إلى',
                controller: toController,
                onMapTap: _selectToOnMap,
              ),

              const SizedBox(height: 18),

              // أماكن مقترحة
              _sectionTitle('أماكن مقترحة:'),
              const SizedBox(height: 10),
              _suggestedPlacesGrid(primary),

              const SizedBox(height: 22),

              // اختيار نوع المسار
              _sectionTitle('اختر نوع المسار:'),
              const SizedBox(height: 12),
              _pathTypeChips(primary),

              // نزّل الزر شوي بدون ما يلتصق بأسفل الصفحة
              const SizedBox(height: kButtonTopGap),

              // زر البحث
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _searchPath,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    'ابحث عن المسار الآمن',
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              // مساحة بسيطة عشان ما يلتصق بالفوتر
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ======= Widgets داخلية =======

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _suggestedPlacesGrid(Color primary) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: recentPlaces.map((place) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 16 * 2 - 12 * 2) / 3,
          child: InkWell(
            onTap: () => toController.text = place,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  place,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _pathTypeChips(Color primary) {
    Widget chip({
      required IconData icon,
      required String type,
    }) {
      final bool selected = selectedPathType == type;
      return GestureDetector(
        onTap: () => setState(() => selectedPathType = type),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? primary : Colors.white,
            border: Border.all(color: primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            size: 28,
            color: selected ? Colors.white : primary,
          ),
        ),
      );
    }

    // إنزال الأيقونات للوسط شوي
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          chip(icon: Icons.directions_walk, type: 'walk'),
          chip(icon: Icons.directions_bike, type: 'bike'),
          chip(icon: Icons.accessible, type: 'wheelchair'),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onMapTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.black87, fontSize: 15.5),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'اكتب اسم المكان أو أدخل الإحداثيات (lat, lng)',
        labelStyle: TextStyle(color: primary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withOpacity(.9), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        // زر مسح
        prefixIcon: IconButton(
          tooltip: 'مسح',
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
        // زر خريطة
        suffixIcon: IconButton(
          tooltip: 'اختيار من الخريطة',
          onPressed: onMapTap,
          icon: Icon(Icons.map, color: primary),
        ),
      ),
    );
  }
}
