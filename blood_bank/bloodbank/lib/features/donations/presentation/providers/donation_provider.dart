import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloodbank/features/donations/domain/donation_model.dart';
import 'package:bloodbank/features/auth/presentation/providers/auth_provider.dart';

// Mock data source - replace with actual API calls
class DonationDataSource {
  final List<Donation> _donations = [];
  
  Future<List<Donation>> getUserDonations(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _donations.where((d) => d.donorId == userId).toList();
  }
  
  Future<void> addDonation(Donation donation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _donations.add(donation);
  }
  
  Future<void> verifyDonation(String donationId, String adminName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index != -1) {
      final donation = _donations[index];
      _donations[index] = Donation(
        id: donation.id,
        donorId: donation.donorId,
        donorName: donation.donorName,
        bloodType: donation.bloodType,
        donationDate: donation.donationDate,
        pointsAwarded: donation.pointsAwarded,
        isVerified: true,
        verifiedBy: adminName,
        verificationDate: DateTime.now(),
      );
    }
  }
}

class DonationProvider with ChangeNotifier {
  final DonationDataSource _dataSource = DonationDataSource();
  final AuthProvider _authProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Donation> _donations = [];
  bool _isLoading = false;
  String? _error;

  DonationProvider(this._authProvider);

  List<Donation> get donations => _donations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all donations for the current user
  Future<void> fetchUserDonations() async {
    if (_authProvider.userId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donations = await _dataSource.getUserDonations(_authProvider.userId!);
    } catch (e) {
      _error = 'فشل تحميل سجل التبرعات';
      if (kDebugMode) {
        print('Error fetching donations: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all donations (admin only)
  Future<List<Donation>> getAllDonations() async {
    if (!_authProvider.isAdmin) {
      if (kDebugMode) {
        print('Unauthorized access: User is not an admin');
      }
      return [];
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _firestore
          .collection('donations')
          .orderBy('donationDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Donation.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      _error = 'فشل تحميل سجل التبرعات: ${e.message}';
      if (kDebugMode) {
        print('Firebase Error fetching all donations: $e');
      }
      return [];
    } catch (e) {
      _error = 'حدث خطأ غير متوقع';
      if (kDebugMode) {
        print('Unexpected error fetching all donations: $e');
      }
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new donation
  Future<bool> addDonation({
    required String donorName,
    required String bloodType,
  }) async {
    if (_authProvider.userId == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if user can donate again
      final lastDonation = _donations.isNotEmpty ? _donations.first : null;
      if (lastDonation != null && !lastDonation.canDonateAgain) {
        _error = 'لا يمكنك التبرع مرة أخرى إلا بعد مرور 6 أشهر من آخر تبرع';
        return false;
      }

final newDonation = Donation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        donorId: _authProvider.userId!,
        donorName: donorName,
        bloodType: bloodType,
        donationDate: DateTime.now(),
      );
      
      await _dataSource.addDonation(newDonation);
      _donations.insert(0, newDonation);
      return true;
    } catch (e) {
      _error = 'فشل إضافة التبرع';
      if (kDebugMode) {
        print('Error adding donation: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify a donation (admin only)
  Future<bool> verifyDonation(String donationId, String adminName) async {
    if (!_authProvider.isAdmin) return false;
    
    try {
      await _dataSource.verifyDonation(donationId, adminName);
      
      // Update local state
      final index = _donations.indexWhere((d) => d.id == donationId);
      if (index != -1) {
        final updated = _donations[index];
        _donations[index] = Donation(
          id: updated.id,
          donorId: updated.donorId,
          donorName: updated.donorName,
          bloodType: updated.bloodType,
          donationDate: updated.donationDate,
          pointsAwarded: updated.pointsAwarded,
          isVerified: true,
          verifiedBy: adminName,
          verificationDate: DateTime.now(),
        );
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying donation: $e');
      }
      return false;
    } finally {
      notifyListeners();
    }
  }
}
