import 'package:autoledger/features/vehicles/domain/vehicle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final _client = Supabase.instance.client;

  Future<void> addVehicle({
    required String brand,
    required String model,
    required int year,
    String? nickname,
    String? plateAlias,
    required String fuelType,
    required int currentKm,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    await _client.from('vehicles').insert({
      'user_id': user.id,
      'brand': brand,
      'model': model,
      'year': year,
      'nickname': nickname?.trim().isEmpty == true ? null : nickname?.trim(),
      'plate_alias': plateAlias?.trim().isEmpty == true ? null : plateAlias?.trim(),
      'fuel_type': fuelType,
      'current_km': currentKm,
    });
  }

  Future<List<Vehicle>> getVehicles() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final response = await _client
        .from('vehicles')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Vehicle.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}