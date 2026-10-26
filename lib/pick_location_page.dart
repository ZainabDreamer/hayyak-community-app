// By : Afnan 
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PickLocationPage extends StatefulWidget {
  final String title;

  const PickLocationPage({super.key, required this.title});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng? selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(26.4, 50.1),
          initialZoom: 14,
          onTap: (_, point) {
            setState(() {
              selectedPoint = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.safe_path',
          ),
          if (selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 50,
                  height: 50,
                  point: selectedPoint!,
                  child: const Icon(Icons.location_pin,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: selectedPoint == null
              ? null
              : () {
                  Navigator.pop(context, selectedPoint);
                },
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(
            'تأكيد الاختيار',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF338C9A),
            disabledBackgroundColor: Colors.grey,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), 
            ),
            elevation: 3,
          ),
        ),
      ),
    );
  }
}
