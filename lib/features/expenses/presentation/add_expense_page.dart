import 'package:autoledger/core/formatters/thousands_separator_input_formatter.dart';
import 'package:autoledger/features/expenses/data/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  final String vehicleId;

  const AddExpensePage({
    super.key,
    required this.vehicleId,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final expenseService = ExpenseService();

  final amountController = TextEditingController();
  final odometerKmController = TextEditingController();
  final notesController = TextEditingController();

  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');

  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  String selectedCategory = 'Yakıt';

  final List<String> categories = [
    'Yakıt',
    'Periyodik Bakım',
    'Tamir / Arıza',
    'Lastik',
    'Sigorta',
    'Vergi',
    'Muayene',
    'Ceza',
    'Otopark',
    'Yıkama / Detaylı Temizlik',
    'Aksesuar / Kişiselleştirme',
    'Diğer',
  ];

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> saveExpense() async {
    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutar alanı zorunludur.')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final amountText = amountController.text.replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(amountText);

      if (amount == null) {
        throw Exception('Geçerli bir tutar gir.');
      }

      final odometerKm = odometerKmController.text.trim().isEmpty
          ? null
          : int.tryParse(odometerKmController.text.replaceAll('.', ''));

      await expenseService.addExpense(
        vehicleId: widget.vehicleId,
        category: selectedCategory,
        amount: amount,
        expenseDate: selectedDate,
        odometerKm: odometerKm,
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gider eklendi.')),
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
    amountController.dispose();
    odometerKmController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gider Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              items: categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCategory = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Kategori *',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Tutar *',
                hintText: 'Örn: 1250,50',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tarih *',
                ),
                child: Text(dateFormatter.format(selectedDate)),
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
                onPressed: isLoading ? null : saveExpense,
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