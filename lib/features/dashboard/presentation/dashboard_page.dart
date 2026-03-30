import 'package:autoledger/features/vehicles/data/vehicle_service.dart';
import 'package:autoledger/features/vehicles/domain/vehicle.dart';
import 'package:autoledger/features/vehicles/presentation/add_vehicle_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final vehicleService = VehicleService();
final NumberFormat kmFormatter = NumberFormat('#,###', 'tr_TR');

  List<Vehicle> vehicles = [];
  bool isLoading = true;
  String? fullName;

  @override
  void initState() {
    super.initState();
    loadPage();
  }

  Future<void> loadPage() async {
    await Future.wait([
      loadVehicles(),
      loadProfile(),
    ]);
  }

  Future<void> loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          fullName = response?['full_name'];
        });
      }
    } catch (_) {}
  }

  Future<void> loadVehicles() async {
    try {
      setState(() => isLoading = true);
      final data = await vehicleService.getVehicles();
      setState(() => vehicles = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Araçlar yüklenemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> goToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddVehiclePage(),
      ),
    );

    if (result == true) {
      await loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoLedger'),
        actions: [
          IconButton(
            onPressed: goToAddVehicle,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadPage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: const Text('Hoş geldin'),
                subtitle: Text(
                  fullName?.isNotEmpty == true
                      ? fullName!
                      : (user?.email ?? 'Kullanıcı'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Araçlarım',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (vehicles.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Henüz araç eklemedin.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: goToAddVehicle,
                        child: const Text('İlk aracı ekle'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...vehicles.map(
                (vehicle) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      title: Text('${vehicle.brand} ${vehicle.model}'),
                      subtitle: Text(
  '${vehicle.year} • ${vehicle.fuelType} • ${kmFormatter.format(vehicle.currentKm).replaceAll(',', '.')} km',
),
                      trailing: vehicle.nickname != null &&
                              vehicle.nickname!.isNotEmpty
                          ? Text(vehicle.nickname!)
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}