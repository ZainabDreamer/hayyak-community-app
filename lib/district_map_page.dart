// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DistrictMapPage extends StatelessWidget {
  final List<Map<String, dynamic>> districts = [
    {
      'name': 'حي الشاطئ',
      'rating': 4.8,
      'location': LatLng(26.4467, 50.0954),
    },
    {
      'name': 'حي الراكة',
      'rating': 5.0,
      'location': LatLng(26.3687, 50.1904),
    },
    {
      'name': 'حي السلام',
      'rating': 4.5,
      'location': LatLng(26.4520, 50.1046),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF2ED),
        body: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(26.4, 50.1),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.safe_path',
            ),
            MarkerLayer(
              markers: districts.map((district) {
                return Marker(
                  width: 100,
                  height: 100,
                  point: district['location'],
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم اختيار ${district['name']}'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF338C9A),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            district['rating'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
