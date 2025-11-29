import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(fontFamily: 'Tajawal')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardItem(
            context,
            icon: Icons.people,
            label: 'إدارة المستخدمين',
            onTap: () {
              // TODO: Navigate to users management
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bloodtype,
            label: 'طلبات التبرع',
            onTap: () {
              // TODO: Navigate to donation requests
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.analytics,
            label: 'إحصائيات',
            onTap: () {
              // TODO: Show analytics
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.campaign,
            label: 'الحملات',
            onTap: () {
              // TODO: Manage campaigns
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
