class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bloodType;
  final String city;
  final bool isDonor;
  final DateTime? lastDonationDate;
  final int totalDonations;
  final int points;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.bloodType,
    required this.city,
    this.isDonor = true,
    this.lastDonationDate,
    this.totalDonations = 0,
    this.points = 0,
  });

  // Helper method to check if user can donate
  bool get canDonate {
    if (lastDonationDate == null) return true;
    final difference = DateTime.now().difference(lastDonationDate!).inDays;
    return difference >= 56; // 8 weeks minimum between donations
  }

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'bloodType': bloodType,
      'city': city,
      'isDonor': isDonor,
      'lastDonationDate': lastDonationDate?.toIso8601String(),
      'totalDonations': totalDonations,
      'points': points,
    };
  }

  // Create from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bloodType: map['bloodType'] ?? 'غير محدد',
      city: map['city'] ?? 'غير محدد',
      isDonor: map['isDonor'] ?? true,
      lastDonationDate: map['lastDonationDate'] != null 
          ? DateTime.parse(map['lastDonationDate']) 
          : null,
      totalDonations: map['totalDonations'] ?? 0,
      points: map['points'] ?? 0,
    );
  }
}
