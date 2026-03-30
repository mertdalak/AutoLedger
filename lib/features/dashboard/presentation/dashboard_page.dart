import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoLedger'),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Hoş geldin'),
                subtitle: Text(user?.email ?? 'Kullanıcı'),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Dashboard buraya gelecek.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}