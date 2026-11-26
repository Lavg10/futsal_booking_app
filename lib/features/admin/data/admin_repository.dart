import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../owner/domain/owner_application.dart';

class AdminRepository {
  const AdminRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(AppConstants.ownerApplicationsCollection);

  Stream<List<OwnerApplication>> watchPendingApplications() {
    return _applications
        .where('status', isEqualTo: AppConstants.statusPending)
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs.map(OwnerApplication.fromFirestore).toList();
      applications.sort((a, b) {
        final left = a.submittedAt;
        final right = b.submittedAt;
        if (left == null || right == null) return 0;
        return right.compareTo(left);
      });
      return applications;
    });
  }

  Future<OwnerApplication?> getApplication(String uid) async {
    final snapshot = await _applications.doc(uid).get();
    if (!snapshot.exists) return null;
    return OwnerApplication.fromFirestore(snapshot);
  }

  Future<void> approveApplication({
    required OwnerApplication application,
    required String adminUid,
  }) async {
    final batch = _firestore.batch();
    batch.update(_applications.doc(application.uid), {
      'status': AppConstants.statusApproved,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
      'rejectionReason': FieldValue.delete(),
    });
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(application.uid),
      {'approvalStatus': AppConstants.statusApproved},
    );
    batch.set(
      _firestore.collection(AppConstants.ownersCollection).doc(application.uid),
      {
        'uid': application.uid,
        'ownerName': application.ownerName,
        'businessName': application.businessName,
        'registrationNumber': application.registrationNumber,
        'phoneNumber': application.phoneNumber,
        'address': application.address,
        'latitude': application.latitude,
        'longitude': application.longitude,
        'isActive': true,
        'approvedBy': adminUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'documents': application.documents.toMap(),
      },
    );
    await batch.commit();
  }

  Future<void> rejectApplication({
    required String uid,
    required String reason,
    required String adminUid,
  }) async {
    final batch = _firestore.batch();
    batch.update(_applications.doc(uid), {
      'status': AppConstants.statusRejected,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
      'rejectionReason': reason.trim(),
    });
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(uid),
      {'approvalStatus': AppConstants.statusRejected},
    );
    await batch.commit();
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(FirebaseFirestore.instance);
});

final pendingOwnerApplicationsProvider = StreamProvider<List<OwnerApplication>>((ref) {
  return ref.watch(adminRepositoryProvider).watchPendingApplications();
});
