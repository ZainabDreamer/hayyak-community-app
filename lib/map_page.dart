// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  // إحداثيات الموقع
  static const LatLng _location = LatLng(26.381633606621783, 50.23327323973756);

  // رابط فتح الموقع في Google Maps
  static const String _mapUrl =
      'https://maps.google.com/?q=26.381633606621783,50.23327323973756';

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // عنوان ووصف مختصرين
          const Text(
            'الخريطة التفاعلية',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'تظهر هنا خريطة الحي والمواقع المهمة بدقة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // الكارد الذي يحتوي الخريطة
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: _location,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _location,
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.location_on,
                            color: accent, 
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

         
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(_mapUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.map_outlined, color: Colors.white, size: 18),
              label: const Text(
                'افتح الموقع على الخريطة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(293.31, 46), 
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(height: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
