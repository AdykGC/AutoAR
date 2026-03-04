class Machine {
  final int id;
  final String name;
  final String type;
  final String? location;
  final String? serialNumber;

  // Новые поля
  final String? connectionType;
  final double? installPrice;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    this.location,
    this.serialNumber,
    this.connectionType,
    this.installPrice,
    this.latitude,
    this.longitude,
    this.isActive = true, // по умолчанию активный
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      serialNumber: json['serial_number'],
      connectionType: json['connection_type'],
      installPrice: json['install_price'] != null
          ? double.tryParse(json['install_price'].toString())
          : null,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Machine copyWith({
    int? id,
    String? name,
    String? type,
    String? location,
    String? serialNumber,
    String? connectionType,
    double? installPrice,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      connectionType: connectionType ?? this.connectionType,
      installPrice: installPrice ?? this.installPrice,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }

}
