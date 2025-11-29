import 'package:flutter/foundation.dart';

/// User roles for the application
enum UserRole { admin, user, guest }

/// User model for authentication
class AppUser {
  final String uid;
  final String? email;
  final UserRole role;
  final String? displayName;
  final String? phoneNumber;
  final String? city;
  final bool isDonor;
  final DateTime? lastDonationDate;

  AppUser({
    required this.uid,
    this.email,
    required this.role,
    this.displayName,
    this.phoneNumber,
    this.city,
    this.isDonor = false,
    this.lastDonationDate,
  });

  // Convert User to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.toString(),
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'city': city,
      'isDonor': isDonor,
      'lastDonationDate': lastDonationDate?.toIso8601String(),
    };
  }

  // Create User from a Map
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => UserRole.user,
      ),
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      city: map['city'],
      isDonor: map['isDonor'] ?? false,
      lastDonationDate: map['lastDonationDate'] != null 
          ? DateTime.parse(map['lastDonationDate']) 
          : null,
    );
  }
}

/// Manages authentication state for the application
class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  UserRole get userRole => _user?.role ?? UserRole.guest;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _user?.uid;
  String? get displayName => _user?.displayName ?? _user?.email?.split('@').first;

  // Demo admin credentials
  static const String demoAdminEmail = 'admin@bloodbank.com';
  static const String demoAdminPassword = 'admin123';

  // Demo user credentials
  static const String demoUserEmail = 'user@example.com';
  static const String demoUserPassword = 'user123';

  /// Attempts to log in a user with the provided credentials
  /// 
  /// Returns `true` if login is successful, `false` otherwise
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes - in a real app, this would validate against a backend
      if (email == demoAdminEmail && password == demoAdminPassword) {
        _user = AppUser(
          uid: 'admin-123',
          email: email,
          role: UserRole.admin,
          displayName: 'مدير النظام',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == demoUserEmail && password == demoUserPassword) {
        _user = AppUser(
          uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          role: UserRole.user,
          displayName: 'مستخدم',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول';
      _isLoading = false;
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    _user = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Gets the current user's ID
  String? getCurrentUserId() {
    return _user?.uid;
  }

  /// Checks if the current user is the owner of a resource
  bool isOwner(String? resourceOwnerId) {
    if (resourceOwnerId == null) return false;
    return _user?.uid == resourceOwnerId;
  }
}
