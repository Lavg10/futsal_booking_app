import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';

enum AppRole { user, owner, admin }

enum ApprovalStatus { none, pending, approved, rejected }

extension AppRoleX on AppRole {
  String get value => name;

  static AppRole fromValue(String value) {
    return AppRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => AppRole.user,
    );
  }
}

extension ApprovalStatusX on ApprovalStatus {
  String get value => name;

  static ApprovalStatus fromValue(String? value) {
    if (value == null) return ApprovalStatus.none;
    return ApprovalStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ApprovalStatus.none,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.approvalStatus,
    this.phoneNumber = '',
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final AppRole role;
  final ApprovalStatus approvalStatus;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  bool get isAdmin => role == AppRole.admin;
  bool get isApprovedOwner =>
      role == AppRole.owner && approvalStatus == ApprovalStatus.approved;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: AppRoleX.fromValue(data['role'] as String? ?? AppConstants.roleUser),
      approvalStatus:
          ApprovalStatusX.fromValue(data['approvalStatus'] as String?),
      phoneNumber: data['phoneNumber'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'approvalStatus': approvalStatus.value,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
