/* [ Flutter ] */
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/* [ Packages ] */
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class SelectLocationPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? location;

  const SelectLocationPage({
    super.key,
    this.latitude,
    this.longitude,
    this.location,
  });

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {

  LatLng? selectedPoint;

  final TextEditingController searchController = TextEditingController();
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  /// =====================================================
  /// Определяем начальную позицию карты
  /// =====================================================

  Future<void> _initializeLocation() async {

    /// если есть координаты
    if (widget.latitude != null && widget.longitude != null) {

      selectedPoint = LatLng(widget.latitude!, widget.longitude!);

    }

    /// если есть адрес
    else if (widget.location != null && widget.location!.isNotEmpty) {

      try {

        final locations = await locationFromAddress(widget.location!);

        if (locations.isNotEmpty) {

          final loc = locations.first;

          selectedPoint = LatLng(
            loc.latitude,
            loc.longitude,
          );

        }

      } catch (_) {}

    }

    /// иначе используем GPS
    else {

      try {

        await Geolocator.requestPermission();

        final position = await Geolocator.getCurrentPosition();

        selectedPoint = LatLng(
          position.latitude,
          position.longitude,
        );

      } catch (_) {

        /// fallback Almaty
        selectedPoint = const LatLng(43.2075, 76.6699);

      }

    }

    setState(() {});
  }

  /// =====================================================
  /// Поиск адреса
  /// =====================================================

  Future<void> _searchLocation() async {

    final query = searchController.text.trim();

    if (query.isEmpty) return;

    try {

      final locations = await locationFromAddress(query);

      if (locations.isEmpty) return;

      final location = locations.first;

      final point = LatLng(
        location.latitude,
        location.longitude,
      );

      setState(() {
        selectedPoint = point;
      });

      mapController.move(point, 16);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Адрес не найден"),
        ),
      );

    }

  }

  /// =====================================================
  /// Получение адреса по координатам
  /// =====================================================

  Future<String?> _getAddress(LatLng point) async {

    try {

      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isEmpty) return null;

      final p = placemarks.first;

      return "${p.street}, ${p.locality}";

    } catch (_) {

      return null;

    }

  }

  /// =====================================================
  /// Сохранение точки
  /// =====================================================

  Future<void> _saveLocation() async {

    if (selectedPoint == null) return;

    final address = await _getAddress(selectedPoint!);

    Navigator.pop(
      context,
      {
        "latitude": selectedPoint!.latitude,
        "longitude": selectedPoint!.longitude,
        "location": address,
      },
    );

  }

  @override
  Widget build(BuildContext context) {

    /// пока координаты не определены
    if (selectedPoint == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );

    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Выбрать координаты"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLocation,
          )
        ],
      ),

      body: Column(
        children: [

          /// =========================
          /// Поле поиска
          /// =========================

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(

                hintText: "Поиск адреса",

                prefixIcon: const Icon(Icons.search),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _searchLocation,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onSubmitted: (_) => _searchLocation(),
            ),
          ),

          /// =========================
          /// Карта
          /// =========================

          Expanded(
            child: FlutterMap(

              mapController: mapController,

              options: MapOptions(
                initialCenter: selectedPoint!,
                initialZoom: 15,

                onTap: (tapPosition, point) {
                  setState(() {
                    selectedPoint = point;
                  });
                },
              ),

              children: [

                TileLayer(
                  urlTemplate:
                      'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.app',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}