import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MachineMapWidget extends StatelessWidget {
    final double latitude;
    final double longitude;
    final Function(LatLng) onTap;

  const MachineMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white54),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15,
            onTap: (tapPosition, point) => onTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png',
              subdomains: ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}