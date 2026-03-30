import 'package:autoledger/features/service_records/domain/service_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRecordService {
  final _client = Supabase.instance.client;

  Future<void> addServiceRecord({
    required String vehicleId,
    required String serviceType,
    required DateTime serviceDate,
    int? odometerKm,
    required double totalCost,
    String? servicePlace,
    String? notes,
    DateTime? nextServiceDate,
    int? nextServiceKm,
    required List<String> items,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final inserted = await _client
        .from('service_records')
        .insert({
          'user_id': user.id,
          'vehicle_id': vehicleId,
          'service_type': serviceType,
          'service_date': serviceDate.toIso8601String().split('T').first,
          'odometer_km': odometerKm,
          'total_cost': totalCost,
          'service_place': servicePlace?.trim().isEmpty == true
              ? null
              : servicePlace?.trim(),
          'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
          'next_service_date': nextServiceDate != null
              ? nextServiceDate.toIso8601String().split('T').first
              : null,
          'next_service_km': nextServiceKm,
        })
        .select()
        .single();

    final serviceRecordId = inserted['id'] as String;

    if (items.isNotEmpty) {
      final rows = items
          .map(
            (item) => {
              'user_id': user.id,
              'service_record_id': serviceRecordId,
              'item_name': item,
            },
          )
          .toList();

      await _client.from('service_record_items').insert(rows);
    }
  }

  Future<List<ServiceRecord>> getServiceRecordsByVehicle(String vehicleId) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final response = await _client
        .from('service_records')
        .select()
        .eq('user_id', user.id)
        .eq('vehicle_id', vehicleId)
        .order('service_date', ascending: false)
        .order('created_at', ascending: false);

    final records = <ServiceRecord>[];

    for (final item in response as List) {
      final map = item as Map<String, dynamic>;
      final recordId = map['id'] as String;

      final itemsResponse = await _client
          .from('service_record_items')
          .select('item_name')
          .eq('user_id', user.id)
          .eq('service_record_id', recordId);

      final items = (itemsResponse as List)
          .map((e) => (e as Map<String, dynamic>)['item_name'] as String)
          .toList();

      records.add(ServiceRecord.fromMap(map, items: items));
    }

    return records;
  }
}