import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'admin_reports_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('الوحة الإدارية')),
        body: const Center(
          child: Text('غير مصرح لك بالوصول إلى هذه الصفحة'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الوحة الإدارية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardItem(
            context,
            title: 'التقارير',
            icon: Icons.analytics,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminReportsScreen(),
                ),
              );
            },
          ),
          _buildDashboardItem(
            context,
            title: 'إدارة المتبرعين',
            icon: Icons.people,
            color: Colors.green,
            onTap: () {
              // TODO: Navigate to donors management
            },
          ),
          _buildDashboardItem(
            context,
            title: 'إدارة الطلبات',
            icon: Icons.request_quote,
            color: Colors.orange,
            onTap: () {
              // TODO: Navigate to requests management
            },
          ),
          _buildDashboardItem(
            context,
            title: 'إشعارات',
            icon: Icons.notifications,
            color: Colors.purple,
            onTap: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
