class BloodRequest {
  final String id;
  final String patientName;
  final String bloodType;
  final String hospitalName;
  final String city;
  final String contactNumber;
  final String caseDescription;
  final String hospitalLocation;
  final int unitsNeeded;
  final int unitsDonated;
  final bool isUrgent;
  final DateTime? requiredDate;
  final DateTime createdAt; // Add this line
  final String createdBy;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.bloodType,
    required this.hospitalName,
    required this.city,
    required this.contactNumber,
    required this.caseDescription,
    required this.hospitalLocation,
    required this.unitsNeeded,
    this.unitsDonated = 0,
    this.isUrgent = false,
    this.requiredDate,
    required this.createdAt, // Add this line
    required this.createdBy,
  });

  // Add toMap and fromJson methods if you have them
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'bloodType': bloodType,
      'hospitalName': hospitalName,
      'city': city,
      'contactNumber': contactNumber,
      'caseDescription': caseDescription,
      'hospitalLocation': hospitalLocation,
      'unitsNeeded': unitsNeeded,
      'unitsDonated': unitsDonated,
      'isUrgent': isUrgent,
      'requiredDate': requiredDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(), // Add this line
      'createdBy': createdBy,
    };
  }

  factory BloodRequest.fromMap(Map<String, dynamic> map) {
    return BloodRequest(
      id: map['id'] as String,
      patientName: map['patientName'] as String,
      bloodType: map['bloodType'] as String,
      hospitalName: map['hospitalName'] as String,
      city: map['city'] as String,
      contactNumber: map['contactNumber'] as String,
      caseDescription: map['caseDescription'] as String,
      hospitalLocation: map['hospitalLocation'] as String,
      unitsNeeded: map['unitsNeeded'] as int,
      unitsDonated: map['unitsDonated'] as int,
      isUrgent: map['isUrgent'] as bool,
      requiredDate: map['requiredDate'] != null
          ? DateTime.parse(map['requiredDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String), // Add this line
      createdBy: map['createdBy'] as String,
    );
  }
}
