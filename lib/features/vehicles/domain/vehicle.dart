class Vehicle {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String? nickname;
  final String? plateAlias;
  final String fuelType;
  final int currentKm;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.nickname,
    required this.plateAlias,
    required this.fuelType,
    required this.currentKm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      nickname: map['nickname'] as String?,
      plateAlias: map['plate_alias'] as String?,
      fuelType: map['fuel_type'] as String,
      currentKm: map['current_km'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}