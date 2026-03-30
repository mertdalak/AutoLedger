class Expense {
  final String id;
  final String userId;
  final String vehicleId;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final int? odometerKm;
  final String? notes;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.odometerKm,
    required this.notes,
    required this.createdAt,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      vehicleId: map['vehicle_id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date'] as String),
      odometerKm: map['odometer_km'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}