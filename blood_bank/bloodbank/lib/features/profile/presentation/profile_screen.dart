import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/constants.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/requests/domain/request_model.dart';
import '../../../features/requests/presentation/providers/request_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  List<BloodRequest> _userRequests = [];
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Status helpers
  Color _getStatusColor(bool isUrgent) {
    return isUrgent ? Colors.red : Colors.orange;
  }

  IconData _getStatusIcon(bool isUrgent) {
    return isUrgent ? Icons.warning_amber_rounded : Icons.pending_actions;
  }

  String _getStatusText(bool isUrgent) {
    return isUrgent ? 'حالة طارئة' : 'عادية';
  }

  Future<void> _loadUserData({bool isRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      if (isRefresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final requestProvider = context.read<RequestProvider>();

      if (authProvider.userId != null) {
        final requests = await requestProvider.getUserRequests(
          authProvider.userId!,
        );
        if (mounted) {
          setState(() {
            _userRequests = requests;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل تحميل بيانات المستخدم';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
        // TODO: Upload image to server
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة')),
      );
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _pickedImage != null
                  ? Image.file(
                      _pickedImage!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontSize: 16)),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.user:
        return 'مستخدم عادي';
      case UserRole.guest:
        return 'زائر';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'لم يسبق التبرع';
    final format = DateFormat('yyyy/MM/dd', 'ar');
    return format.format(date);
  }

  Widget _buildUserInfo() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text('لا توجد بيانات للمستخدم'));
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 20),
            _buildInfoRow('الاسم', user.displayName ?? 'مستخدم'),
            const Divider(),
            _buildInfoRow('البريد الإلكتروني', user.email ?? 'غير متوفر'),
            if (user.phoneNumber?.isNotEmpty ?? false) ...[
              const Divider(),
              _buildInfoRow('رقم الهاتف', user.phoneNumber!),
            ],
            const Divider(),
            _buildInfoRow(
              'المدينة',
              user.city?.isNotEmpty == true
                  ? '${user.city} - اليمن'
                  : 'غير محدد',
            ),
            const Divider(),
            _buildInfoRow('نوع الحساب', _getRoleText(user.role)),
            const Divider(),
            _buildInfoRow('حالة المتبرع', user.isDonor ? 'متبرع' : 'غير متبرع'),
            if (user.isDonor) ...[
              const Divider(),
              _buildInfoRow('آخر تبرع', _formatDate(user.lastDonationDate)),
            ],
            const Divider(),
            _buildInfoRow('حالة الحساب', 'نشط'),
            const SizedBox(height: 20),
            if (authProvider.isAdmin)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to admin dashboard
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('لوحة التحكم'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationRequestItem(BloodRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(request.isUrgent).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(request.isUrgent),
            color: _getStatusColor(request.isUrgent),
          ),
        ),
        title: Text(
          request.hospitalName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('فصيلة الدم: ${request.bloodType}'),
            Text('الحالة: ${_getStatusText(request.isUrgent)}'),
            Text(
              'المريض: ${request.patientName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'تاريخ الطلب: ${DateFormat('yyyy/MM/dd').format(request.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to request details
        },
      ),
    );
  }

  Widget _buildDonationRequests() {
    if (_userRequests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'لا توجد طلبات تبرع حتى الآن',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            'طلبات التبرع السابقة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _userRequests.length,
          itemBuilder: (context, index) {
            return _buildDonationRequestItem(_userRequests[index]);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadUserData(isRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    _buildUserInfo(),
                    const SizedBox(height: 16),
                    _buildDonationRequests(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
