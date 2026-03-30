import 'package:autoledger/core/formatters/thousands_separator_input_formatter.dart';
import 'package:autoledger/features/vehicles/data/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final nicknameController = TextEditingController();
  final plateAliasController = TextEditingController();
  final currentKmController = TextEditingController();

  final vehicleService = VehicleService();

  bool isLoading = false;
  String selectedFuelType = 'Benzin';
  int selectedYear = DateTime.now().year;

  final fuelTypes = ['Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'];

  late final List<int> years = List.generate(
    60,
    (index) => DateTime.now().year - index,
  );

  Future<void> saveVehicle() async {
    if (brandController.text.trim().isEmpty ||
        modelController.text.trim().isEmpty ||
        currentKmController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen zorunlu alanları doldur.')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final currentKm =
          int.tryParse(currentKmController.text.replaceAll('.', '')) ?? 0;

      await vehicleService.addVehicle(
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        year: selectedYear,
        nickname: nicknameController.text.trim(),
        plateAlias: plateAliasController.text.trim(),
        fuelType: selectedFuelType,
        currentKm: currentKm,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç eklendi.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    nicknameController.dispose();
    plateAliasController.dispose();
    currentKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'Marka *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: 'Model *'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedYear,
              items: years
                  .map(
                    (year) => DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedYear = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Yıl *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: 'Kayıt Etiketi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateAliasController,
              decoration: const InputDecoration(labelText: 'Plaka'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedFuelType,
              items: fuelTypes
                  .map(
                    (fuel) => DropdownMenuItem(
                      value: fuel,
                      child: Text(fuel),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedFuelType = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Yakıt Tipi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: currentKmController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(labelText: 'Mevcut KM *'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveVehicle,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}