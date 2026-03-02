class Machine {
  final int id;
  final String name;
  final String type;
  final String? location;
  final String? serialNumber;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    this.location,
    this.serialNumber,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      serialNumber: json['serial_number'],
    );
  }
}