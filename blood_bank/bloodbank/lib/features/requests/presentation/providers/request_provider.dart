import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodbank/features/requests/domain/request_model.dart';

/// A provider class that manages blood donation requests.
///
/// This class handles the state and persistence of blood donation requests
/// using [SharedPreferences] for local storage.
class RequestProvider with ChangeNotifier {
  static const String _requestsKey = 'blood_requests';
  List<BloodRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  /// Returns an unmodifiable list of all blood requests
  List<BloodRequest> get allRequests => List.unmodifiable(_requests);
  
  /// Returns the current loading state
  bool get isLoading => _isLoading;
  
  /// Returns the last error message, if any
  String? get error => _error;
  
  /// Loads all blood requests from local storage
  /// 
  /// Updates the internal list of requests and notifies listeners when complete.
  /// Handles any errors that occur during loading.
  Future<void> loadRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getStringList(_requestsKey) ?? [];
      
      _requests = requestsJson.map((json) {
        try {
          return BloodRequest.fromMap(jsonDecode(json));
        } catch (e) {
          debugPrint('Error parsing request: $e');
          return null;
        }
      }).whereType<BloodRequest>().toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load requests';
      _isLoading = false;
      debugPrint('Error loading requests: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Gets all blood requests for a specific user
  /// 
  /// [userId] The ID of the user whose requests to retrieve
  /// Returns a list of [BloodRequest] objects for the specified user
  List<BloodRequest> getUserRequests(String userId) {
    try {
      return _requests
          .where((request) => request.createdBy == userId)
          .toList();
    } catch (e) {
      debugPrint('Error getting user requests: $e');
      return [];
    }
  }

  /// Adds a new blood request
  /// 
  /// [request] The [BloodRequest] to add
  /// Throws an exception if the request cannot be added
  Future<void> addRequest(BloodRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _requests.add(request);
      await _saveRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add request';
      _isLoading = false;
      debugPrint('Error adding request: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Saves all requests to local storage
  Future<void> _saveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = _requests
          .map((request) => jsonEncode(request.toMap()))
          .toList();
      
      final success = await prefs.setStringList(_requestsKey, requestsJson);
      
      if (!success) {
        throw Exception('Failed to save requests to storage');
      }
    } catch (e) {
      debugPrint('Error saving requests: $e');
      rethrow;
    }
  }

  /// Gets a specific blood request by its ID
  /// 
  /// [id] The ID of the request to retrieve
  /// Returns the [BloodRequest] if found, or `null` if not found
  BloodRequest? getRequestById(String id) {
    try {
      return _requests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing blood request
  /// 
  /// [updatedRequest] The updated [BloodRequest] object
  /// Returns `true` if the request was updated, `false` if not found
  /// Throws an exception if the update fails
  Future<bool> updateRequest(BloodRequest updatedRequest) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final index = _requests.indexWhere((r) => r.id == updatedRequest.id);
      if (index == -1) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _requests[index] = updatedRequest;
      await _saveRequests();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update request';
      _isLoading = false;
      debugPrint('Error updating request: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a blood request by its ID
  /// 
  /// [id] The ID of the request to delete
  /// Returns `true` if the request was deleted, `false` if not found
  /// Throws an exception if the deletion fails
  Future<bool> deleteRequest(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final initialLength = _requests.length;
      _requests.removeWhere((request) => request.id == id);
      
      if (_requests.length == initialLength) {
        _isLoading = false;
        notifyListeners();
        return false; // No request was removed
      }
      
      await _saveRequests();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete request';
      _isLoading = false;
      debugPrint('Error deleting request: $e');
      notifyListeners();
      rethrow;
    }
  }
}
