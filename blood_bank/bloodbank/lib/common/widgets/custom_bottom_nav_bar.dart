import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navItems = isAdmin ? _adminNavItems : _userNavItems;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        final route = navItems[index]['route'];
        if (route != null) {
          context.go(route);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.scaffoldBackgroundColor,
      selectedItemColor: theme.primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontFamily: 'Tajawal'),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Tajawal'),
      items: List.generate(
        navItems.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(navItems[index]['icon']),
          activeIcon: Icon(navItems[index]['activeIcon'] ?? navItems[index]['icon']),
          label: navItems[index]['label'],
        ),
      ),
    );
  }

  // Navigation items for admin
  static final List<Map<String, dynamic>> _adminNavItems = [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': 'لوحة التحكم',
      'route': '/',
    },
    {
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
      'label': 'المستخدمين',
      'route': '/users',
    },
    {
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment,
      'label': 'الطلبات',
      'route': '/requests',
    },
    {
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
      'label': 'الإعدادات',
      'route': '/settings',
    },
  ];

  // Navigation items for regular users
  static final List<Map<String, dynamic>> _userNavItems = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'الرئيسية',
      'route': '/requests', // Default to requests for regular users
    },
    {
      'icon': Icons.campaign_outlined,
      'activeIcon': Icons.campaign,
      'label': 'مركز التوعية',
      'route': '/awareness',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'الملف الشخصي',
      'route': '/profile',
    },
  ];

}


