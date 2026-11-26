import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';

class OwnerDocuments {
  const OwnerDocuments({
    required this.idProofUrl,
    required this.businessRegistrationUrl,
    required this.venueProofUrl,
  });

  final String idProofUrl;
  final String businessRegistrationUrl;
  final String venueProofUrl;

  Map<String, dynamic> toMap() => {
        'idProofUrl': idProofUrl,
        'businessRegistrationUrl': businessRegistrationUrl,
        'venueProofUrl': venueProofUrl,
      };

  factory OwnerDocuments.fromMap(Map<String, dynamic> map) {
    return OwnerDocuments(
      idProofUrl: map['idProofUrl'] as String? ?? '',
      businessRegistrationUrl: map['businessRegistrationUrl'] as String? ?? '',
      venueProofUrl: map['venueProofUrl'] as String? ?? '',
    );
  }
}

class OwnerApplication {
  const OwnerApplication({
    required this.uid,
    required this.ownerName,
    required this.email,
    required this.businessName,
    required this.registrationNumber,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.documents,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  final String uid;
  final String ownerName;
  final String email;
  final String businessName;
  final String registrationNumber;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final OwnerDocuments documents;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  bool get isPending => status == AppConstants.statusPending;
  bool get isApproved => status == AppConstants.statusApproved;
  bool get isRejected => status == AppConstants.statusRejected;

  factory OwnerApplication.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return OwnerApplication(
      uid: doc.id,
      ownerName: data['ownerName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      businessName: data['businessName'] as String? ?? '',
      registrationNumber: data['registrationNumber'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      documents: OwnerDocuments.fromMap(
        (data['documents'] as Map<String, dynamic>?) ?? {},
      ),
      status: data['status'] as String? ?? AppConstants.statusPending,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'ownerName': ownerName,
        'email': email,
        'businessName': businessName,
        'registrationNumber': registrationNumber,
        'phoneNumber': phoneNumber,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'documents': documents.toMap(),
        'status': status,
      };
}
