import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/owner_application.dart';
import 'storage_service.dart';

class OwnerRegistrationData {
  const OwnerRegistrationData({
    required this.ownerName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.businessName,
    required this.registrationNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.idProof,
    required this.businessRegistration,
    required this.venueProof,
  });

  final String ownerName;
  final String email;
  final String password;
  final String phoneNumber;
  final String businessName;
  final String registrationNumber;
  final String address;
  final double latitude;
  final double longitude;
  final XFile idProof;
  final XFile businessRegistration;
  final XFile venueProof;
}

class OwnerRepository {
  OwnerRepository(this._auth, this._firestore, this._storage);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final StorageService _storage;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(AppConstants.ownerApplicationsCollection);

  Stream<OwnerApplication?> watchApplication(String uid) {
    return _applications.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return OwnerApplication.fromFirestore(snapshot);
    });
  }

  Future<OwnerApplication?> getApplication(String uid) async {
    final snapshot = await _applications.doc(uid).get();
    if (!snapshot.exists) return null;
    return OwnerApplication.fromFirestore(snapshot);
  }

  Future<void> register(OwnerRegistrationData data) async {
    String? uid;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: data.email.trim(),
        password: data.password,
      );
      final user = credential.user;
      if (user == null) throw StateError('Account creation failed');
      uid = user.uid;
      await user.updateDisplayName(data.ownerName.trim());

      const documents = OwnerDocuments(
        idProofUrl: '',
        businessRegistrationUrl: '',
        venueProofUrl: '',
      );
      final batch = _firestore.batch();
      batch.set(_firestore.collection(AppConstants.usersCollection).doc(uid), {
        ...AppUser(
          uid: uid,
          email: user.email ?? data.email.trim(),
          displayName: data.ownerName.trim(),
          role: AppRole.owner,
          approvalStatus: ApprovalStatus.pending,
          phoneNumber: data.phoneNumber,
          latitude: data.latitude,
          longitude: data.longitude,
          createdAt: DateTime.now(),
        ).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(_applications.doc(uid), {
        ...OwnerApplication(
          uid: uid,
          ownerName: data.ownerName.trim(),
          email: data.email.trim(),
          businessName: data.businessName.trim(),
          registrationNumber: data.registrationNumber.trim(),
          phoneNumber: data.phoneNumber.trim(),
          address: data.address.trim(),
          latitude: data.latitude,
          longitude: data.longitude,
          documents: documents,
          status: AppConstants.statusPending,
          submittedAt: DateTime.now(),
        ).toMap(),
        'submittedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (error) {
      await _auth.currentUser?.delete();
      if (uid != null) {
        try {
          await _applications.doc(uid).delete();
          await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
        } catch (_) {}
      }
      rethrow;
    }

    final ownerUid = uid;
    try {
      final documents = await _uploadDocuments(ownerUid, data);
      await _applications.doc(ownerUid).update({
        'documents': documents.toMap(),
      });
    } catch (_) {}
  }

  Future<void> resubmitDocuments({
    required String uid,
    required OwnerRegistrationData data,
  }) async {
    final documents = await _uploadDocuments(uid, data);
    final batch = _firestore.batch();
    batch.update(_firestore.collection(AppConstants.usersCollection).doc(uid), {
      'approvalStatus': ApprovalStatus.pending.value,
    });
    batch.update(_applications.doc(uid), {
      'documents': documents.toMap(),
      'ownerName': data.ownerName.trim(),
      'email': data.email.trim(),
      'businessName': data.businessName.trim(),
      'registrationNumber': data.registrationNumber.trim(),
      'phoneNumber': data.phoneNumber.trim(),
      'address': data.address.trim(),
      'latitude': data.latitude,
      'longitude': data.longitude,
      'status': AppConstants.statusPending,
      'rejectionReason': FieldValue.delete(),
      'reviewedAt': FieldValue.delete(),
      'reviewedBy': FieldValue.delete(),
      'submittedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<OwnerDocuments> _uploadDocuments(
    String uid,
    OwnerRegistrationData data,
  ) async {
    final path = _storage.ownerDocumentPath(uid, 'documents');
    final idProof = await _storage.uploadImage(
      folderPath: path,
      file: data.idProof,
      fileName: 'id-proof.jpg',
    );
    final businessRegistration = await _storage.uploadImage(
      folderPath: path,
      file: data.businessRegistration,
      fileName: 'business-registration.jpg',
    );
    final venueProof = await _storage.uploadImage(
      folderPath: path,
      file: data.venueProof,
      fileName: 'venue-proof.jpg',
    );
    return OwnerDocuments(
      idProofUrl: idProof,
      businessRegistrationUrl: businessRegistration,
      venueProofUrl: venueProof,
    );
  }
}

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    ref.watch(storageServiceProvider),
  );
});

final myOwnerApplicationProvider = StreamProvider<OwnerApplication?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(ownerRepositoryProvider).watchApplication(uid);
});
