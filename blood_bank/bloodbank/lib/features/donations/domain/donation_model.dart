import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This is a workaround for Timestamp if you're not using Firestore yet
class Timestamp {
  final DateTime dateTime;
  
  Timestamp(this.dateTime);
  
  DateTime toDate() => dateTime;
  
  factory Timestamp.fromDate(DateTime date) => Timestamp(date);
  
  static Timestamp now() => Timestamp(DateTime.now());
}

class Donation extends Equatable {
  final String id;
  final String donorId;
  final String donorName;
  final String bloodType;
  final DateTime donationDate;
  final int pointsAwarded;
  final bool isVerified;
  final String? verifiedBy;
  final DateTime? verificationDate;

  const Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.bloodType,
    required this.donationDate,
    this.pointsAwarded = 10, // Default points per donation
    this.isVerified = false,
    this.verifiedBy,
    this.verificationDate,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'bloodType': bloodType,
      'donationDate': donationDate.toIso8601String(),
      'pointsAwarded': pointsAwarded,
      'isVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verificationDate': verificationDate?.toIso8601String(),
    };
  }

  // Create model from JSON
  factory Donation.fromJson(Map<String, dynamic> json, String id) {
    return Donation(
      id: id,
      donorId: json['donorId'] as String,
      donorName: json['donorName'] as String,
      bloodType: json['bloodType'] as String,
      donationDate: DateTime.parse(json['donationDate'] as String),
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 10,
      isVerified: json['isVerified'] as bool? ?? false,
      verifiedBy: json['verifiedBy'] as String?,
      verificationDate: json['verificationDate'] != null
          ? DateTime.parse(json['verificationDate'] as String)
          : null,
    );
  }

  // Check if donor is eligible to donate again
  bool get canDonateAgain {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return donationDate.isBefore(sixMonthsAgo);
  }

  @override
  List<Object?> get props => [id, donorId, donationDate];
}
