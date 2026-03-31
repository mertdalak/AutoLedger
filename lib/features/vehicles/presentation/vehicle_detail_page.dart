import 'package:autoledger/features/expenses/data/expense_service.dart';
import 'package:autoledger/features/expenses/domain/expense.dart';
import 'package:autoledger/features/service_records/data/service_record_service.dart';
import 'package:autoledger/features/service_records/domain/service_record.dart';
import 'package:autoledger/features/vehicles/domain/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:autoledger/features/expenses/presentation/add_expense_page.dart';
import 'package:autoledger/features/service_records/presentation/add_service_record_page.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailPage({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage>
    with SingleTickerProviderStateMixin {
  final expenseService = ExpenseService();
  final serviceRecordService = ServiceRecordService();

  final NumberFormat currencyFormatter = NumberFormat('#,##0.00', 'tr_TR');
  final NumberFormat kmFormatter = NumberFormat('#,###', 'tr_TR');
  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');

  late TabController _tabController;

  List<Expense> expenses = [];
  List<ServiceRecord> serviceRecords = [];

  bool isExpensesLoading = true;
  bool isServicesLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
  if (mounted) {
    setState(() {});
  }
});
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      loadExpenses(),
      loadServiceRecords(),
    ]);
  }

  Future<void> loadExpenses() async {
    try {
      setState(() => isExpensesLoading = true);
      final data = await expenseService.getExpensesByVehicle(widget.vehicle.id);
      setState(() => expenses = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giderler yüklenemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isExpensesLoading = false);
      }
    }
  }

  Future<void> loadServiceRecords() async {
    try {
      setState(() => isServicesLoading = true);
      final data = await serviceRecordService.getServiceRecordsByVehicle(
        widget.vehicle.id,
      );
      setState(() => serviceRecords = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Servis kayıtları yüklenemedi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isServicesLoading = false);
      }
    }
  }
  
  Future<void> goToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpensePage(vehicleId: widget.vehicle.id),
      ),
    );

    if (result == true) {
      await loadExpenses();
    }
  }
  Future<void> goToAddServiceRecord() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddServiceRecordPage(vehicleId: widget.vehicle.id),
    ),
  );

  if (result == true) {
    await loadServiceRecords();
  }
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatMoney(double value) {
    return '${currencyFormatter.format(value)} ₺';
  }

  String formatKm(int? value) {
    if (value == null) return '-';
    return '${kmFormatter.format(value).replaceAll(',', '.')} km';
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;

    return Scaffold(
      appBar: AppBar(
  title: Text('${vehicle.brand} ${vehicle.model}'),
  actions: [
  IconButton(
    onPressed: _tabController.index == 0
        ? goToAddExpense
        : goToAddServiceRecord,
    icon: const Icon(Icons.add),
    tooltip: _tabController.index == 0
        ? 'Gider ekle'
        : 'Servis ekle',
  ),
],
  bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Giderler'),
            Tab(text: 'Servisler'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: loadExpenses,
                  child: isExpensesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : expenses.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(child: Text('Henüz gider eklenmedi.')),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenses[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(expense.category),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(dateFormatter.format(expense.expenseDate)),
                                        if (expense.odometerKm != null)
                                          Text(formatKm(expense.odometerKm)),
                                        if (expense.notes != null &&
                                            expense.notes!.isNotEmpty)
                                          Text(expense.notes!),
                                      ],
                                    ),
                                    trailing: Text(formatMoney(expense.amount)),
                                  ),
                                );
                              },
                            ),
                ),
                RefreshIndicator(
                  onRefresh: loadServiceRecords,
                  child: isServicesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : serviceRecords.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(child: Text('Henüz servis kaydı eklenmedi.')),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: serviceRecords.length,
                              itemBuilder: (context, index) {
                                final record = serviceRecords[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                record.serviceType,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(formatMoney(record.totalCost)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(dateFormatter.format(record.serviceDate)),
                                        if (record.odometerKm != null)
                                          Text(formatKm(record.odometerKm)),
                                        if (record.servicePlace != null &&
                                            record.servicePlace!.isNotEmpty)
                                          Text('Servis: ${record.servicePlace!}'),
                                        if (record.notes != null &&
                                            record.notes!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(record.notes!),
                                          ),
                                        if (record.items.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Yapılan İşlemler:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...record.items.map(
                                            (item) => Text('• $item'),
                                          ),
                                        ],
                                        if (record.nextServiceDate != null ||
                                            record.nextServiceKm != null) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Sonraki Servis:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (record.nextServiceDate != null)
                                            Text(
                                              'Tarih: ${dateFormatter.format(record.nextServiceDate!)}',
                                            ),
                                          if (record.nextServiceKm != null)
                                            Text(
                                              'KM: ${formatKm(record.nextServiceKm)}',
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}