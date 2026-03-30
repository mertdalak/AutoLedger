import 'package:autoledger/features/expenses/domain/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final _client = Supabase.instance.client;

  Future<void> addExpense({
    required String vehicleId,
    required String category,
    required double amount,
    required DateTime expenseDate,
    int? odometerKm,
    String? notes,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    await _client.from('expenses').insert({
      'user_id': user.id,
      'vehicle_id': vehicleId,
      'category': category,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'odometer_km': odometerKm,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    });
  }

  Future<List<Expense>> getExpensesByVehicle(String vehicleId) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final response = await _client
        .from('expenses')
        .select()
        .eq('user_id', user.id)
        .eq('vehicle_id', vehicleId)
        .order('expense_date', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Expense.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}