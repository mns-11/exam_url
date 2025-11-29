import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bloodbank/features/auth/presentation/providers/auth_provider.dart';

class NewDashboardScreen extends StatelessWidget {
  const NewDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    
    final features = <_Feature>[
      if (isAdmin)
        const _Feature(label: 'التقارير', icon: Icons.analytics, route: '/admin/reports'),
      const _Feature(label: 'طلب جديد', icon: Icons.bloodtype, route: '/request/new'),
      const _Feature(label: 'الحملات', icon: Icons.campaign, route: '/campaigns'),
      const _Feature(label: 'النقاط', icon: Icons.emoji_events, route: '/rewards'),
      const _Feature(label: 'البطاقة الرقمية', icon: Icons.qr_code, route: '/qr', beta: true),
      const _Feature(label: 'التوعية', icon: Icons.health_and_safety, route: '/awareness'),
      const _Feature(label: 'الملف الشخصي', icon: Icons.person, route: '/profile'),
      const _Feature(label: 'الإعدادات', icon: Icons.settings, route: '/settings'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التحكم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final f = features[index];
            return _FeatureCard(feature: f);
          },
        ),
      ),
    );
  }
}

class _Feature {
  final String label;
  final IconData icon;
  final String route;
  final bool beta;

  const _Feature({
    required this.label,
    required this.icon,
    required this.route,
    this.beta = false,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          GoRouter.of(context).push(feature.route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(feature.icon, size: 40, color: Theme.of(context).primaryColor),
                if (feature.beta)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'تجريبي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              feature.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
