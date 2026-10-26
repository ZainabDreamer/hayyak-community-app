// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_layout.dart';
import 'path_search_page.dart'; 

class SafeRouteResultPage extends StatelessWidget {
  final LatLng from;
  final LatLng to;

  const SafeRouteResultPage({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // حسابات المسافة والوقت (نفس المنطق السابق)
    final Distance distance = const Distance();
    final double meters = distance.as(LengthUnit.Meter, from, to);
    final double km = meters / 1000;
    final double estimatedTimeMin = (km / 5) * 60;
    final String supportedModes =
        km < 2 ? 'مناسب للمشي والدراجات' : 'مناسب للمشي فقط';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BaseLayout(
        activeItem: 'routes',
        currentIndex: 1,
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              // ===== المحتوى =====
              Column(
                children: [
                
                  const SizedBox(height: 8),

                  // الخريطة
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: from,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.safe_path',
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [from, to],
                                  color: primary,
                                  strokeWidth: 5,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: from,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_on,
                                      color: Colors.green.shade700, size: 36),
                                ),
                                Marker(
                                  point: to,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.flag,
                                      color: Colors.red, size: 36),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // معلومات المسار — كارد أبيض بظل خفيف
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _infoText('المسافة: ${km.toStringAsFixed(2)} كم'),
                          _infoText(
                              'الوقت التقريبي: ${estimatedTimeMin.toStringAsFixed(0)} دقيقة'),
                          _infoText('نوع المسار: $supportedModes'),
                        ],
                      ),
                    ),
                  ),

                  // زر فتح Google Maps — مقاس/لون موحّد
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 16), // نفس روح الصفحات
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openInGoogleMaps(context),
                        icon: const Icon(Icons.map,
                            color: Colors.white, size: 22),
                        label: const Text(
                          'افتح في Google Maps',
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
                  ),
                ],
              ),

              // زر رجوع عائم فوق الخريطة
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PathSearchPage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _openInGoogleMaps(BuildContext context) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}&travelmode=walking';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح Google Maps')),
      );
    }
  }
}

