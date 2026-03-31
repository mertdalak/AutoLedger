import 'package:autoledger/core/formatters/thousands_separator_input_formatter.dart';
import 'package:autoledger/features/service_records/data/service_record_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddServiceRecordPage extends StatefulWidget {
  final String vehicleId;

  const AddServiceRecordPage({
    super.key,
    required this.vehicleId,
  });

  @override
  State<AddServiceRecordPage> createState() => _AddServiceRecordPageState();
}

class _AddServiceRecordPageState extends State<AddServiceRecordPage> {
  final serviceRecordService = ServiceRecordService();

  final odometerKmController = TextEditingController();
  final totalCostController = TextEditingController();
  final servicePlaceController = TextEditingController();
  final notesController = TextEditingController();
  final nextServiceKmController = TextEditingController();
  final otherItemController = TextEditingController();

  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');

  DateTime serviceDate = DateTime.now();
  DateTime? nextServiceDate;

  bool isLoading = false;
  String selectedServiceType = 'Periyodik Bakım';

  final List<String> serviceTypes = [
    'Periyodik Bakım',
    'Ağır Bakım',
    'Tamir / Arıza',
    'Lastik İşlemi',
    'Klima Bakımı',
    'Kaporta / Boya',
    'Elektrik / Elektronik',
    'Diğer',
  ];

  final List<String> serviceItems = [
    'Motor yağı değişti',
    'Yağ filtresi değişti',
    'Hava filtresi değişti',
    'Polen filtresi değişti',
    'Yakıt filtresi değişti',
    'Fren balatası değişti',
    'Fren diskleri değişti',
    'Şanzıman yağı değişti',
    'Antifriz değişti',
    'Akü değişti',
    'Klima bakımı yapıldı',
    'Buji değişti',
    'Triger seti değişti',
    'Lastik rotasyonu yapıldı',
    'Genel kontrol yapıldı',
  ];

  late Map<String, bool> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = {
      for (final item in serviceItems) item: false,
    };
  }

  Future<void> pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => serviceDate = picked);
    }
  }

  Future<void> pickNextServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: nextServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => nextServiceDate = picked);
    }
  }

  Future<void> saveServiceRecord() async {
    if (totalCostController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toplam ücret zorunludur.')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final totalCostText =
          totalCostController.text.replaceAll('.', '').replaceAll(',', '.');
      final totalCost = double.tryParse(totalCostText);

      if (totalCost == null) {
        throw Exception('Geçerli bir ücret gir.');
      }

      final odometerKm = odometerKmController.text.trim().isEmpty
          ? null
          : int.tryParse(odometerKmController.text.replaceAll('.', ''));

      final nextKm = nextServiceKmController.text.trim().isEmpty
          ? null
          : int.tryParse(nextServiceKmController.text.replaceAll('.', ''));

      final items = selectedItems.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (otherItemController.text.trim().isNotEmpty) {
        items.add('Diğer: ${otherItemController.text.trim()}');
      }

      await serviceRecordService.addServiceRecord(
        vehicleId: widget.vehicleId,
        serviceType: selectedServiceType,
        serviceDate: serviceDate,
        odometerKm: odometerKm,
        totalCost: totalCost,
        servicePlace: servicePlaceController.text.trim(),
        notes: notesController.text.trim(),
        nextServiceDate: nextServiceDate,
        nextServiceKm: nextKm,
        items: items,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servis kaydı eklendi.')),
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
    odometerKmController.dispose();
    totalCostController.dispose();
    servicePlaceController.dispose();
    notesController.dispose();
    nextServiceKmController.dispose();
    otherItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Kaydı Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedServiceType,
              items: serviceTypes
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedServiceType = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Servis Tipi *',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: pickServiceDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Servis Tarihi *',
                ),
                child: Text(dateFormatter.format(serviceDate)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: odometerKmController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'KM',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: totalCostController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Toplam Ücret *',
                hintText: 'Örn: 4250,00',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: servicePlaceController,
              decoration: const InputDecoration(
                labelText: 'Servis / Usta / Firma',
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Yapılan İşlemler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: serviceItems.map((item) {
                  return CheckboxListTile(
                    value: selectedItems[item],
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        selectedItems[item] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otherItemController,
              decoration: const InputDecoration(
                labelText: 'Diğer İşlem Notu',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: pickNextServiceDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Sonraki Servis Tarihi',
                ),
                child: Text(
                  nextServiceDate != null
                      ? dateFormatter.format(nextServiceDate!)
                      : 'Seçilmedi',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nextServiceKmController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Sonraki Servis KM',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Not',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveServiceRecord,
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