class ServiceRecord {
  final String id;
  final String userId;
  final String vehicleId;
  final String serviceType;
  final DateTime serviceDate;
  final int? odometerKm;
  final double totalCost;
  final String? servicePlace;
  final String? notes;
  final DateTime? nextServiceDate;
  final int? nextServiceKm;
  final List<String> items;
  final DateTime createdAt;

  ServiceRecord({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.serviceType,
    required this.serviceDate,
    required this.odometerKm,
    required this.totalCost,
    required this.servicePlace,
    required this.notes,
    required this.nextServiceDate,
    required this.nextServiceKm,
    required this.items,
    required this.createdAt,
  });

  factory ServiceRecord.fromMap(
    Map<String, dynamic> map, {
    List<String> items = const [],
  }) {
    return ServiceRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      vehicleId: map['vehicle_id'] as String,
      serviceType: map['service_type'] as String,
      serviceDate: DateTime.parse(map['service_date'] as String),
      odometerKm: map['odometer_km'] as int?,
      totalCost: (map['total_cost'] as num).toDouble(),
      servicePlace: map['service_place'] as String?,
      notes: map['notes'] as String?,
      nextServiceDate: map['next_service_date'] != null
          ? DateTime.parse(map['next_service_date'] as String)
          : null,
      nextServiceKm: map['next_service_km'] as int?,
      items: items,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}