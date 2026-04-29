class Machine {
  final int id;
  final String name;
  final String type;
  final String? location;
  final String? serialNumber;
  final String? connectionType;
  final double? installPrice;
  final double? priceAdjustment;
  final double? latitude;
  final double? longitude;
  final String? qrCode;
  final bool isActive;
  final double? balance;
  final String? macAddress;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    this.location,
    this.serialNumber,
    this.connectionType,
    this.installPrice,
    this.priceAdjustment,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.qrCode,
    this.balance,
    this.macAddress,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      serialNumber: json['serial_number'],       // ✅ исправлено
      connectionType: json['connection_type'],
      installPrice: json['install_price'] != null
          ? double.tryParse(json['install_price'].toString()) : null,
      priceAdjustment: json['price_adjustment'] != null
          ? double.tryParse(json['price_adjustment'].toString()) : null,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString()) : null,
      qrCode: json['qr_code'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      balance: json['balance'] != null
          ? double.tryParse(json['balance'].toString()) : null,
      macAddress: json['mac_address'],           // ✅ отдельно
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
    double? priceAdjustment,   // ✅ добавлено
    double? latitude,
    double? longitude,
    bool? isActive,
    String? qrCode,
    double? balance,           // ✅ добавлено
    String? macAddress,        // ✅ добавлено
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      connectionType: connectionType ?? this.connectionType,
      installPrice: installPrice ?? this.installPrice,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,  // ✅
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      qrCode: qrCode ?? this.qrCode,
      balance: balance ?? this.balance,          // ✅
      macAddress: macAddress ?? this.macAddress, // ✅
    );
  }
}