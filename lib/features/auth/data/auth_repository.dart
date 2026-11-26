import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  Stream<AppUser?> watchCurrentUser() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _users.doc(user.uid).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        return AppUser.fromFirestore(snapshot);
      });
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) return;

    final snapshot = await _users.doc(user.uid).get();
    if (snapshot.exists) return;

    await _users.doc(user.uid).set({
      ...AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        displayName: user.displayName ?? '',
        role: AppRole.user,
        approvalStatus: ApprovalStatus.none,
        createdAt: DateTime.now(),
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    double? latitude,
    double? longitude,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Account creation failed');

    try {
      await user.updateDisplayName(name.trim());
      await _users.doc(user.uid).set({
        ...AppUser(
          uid: user.uid,
          email: user.email ?? email.trim(),
          displayName: name.trim(),
          role: AppRole.user,
          approvalStatus: ApprovalStatus.none,
          latitude: latitude,
          longitude: longitude,
          createdAt: DateTime.now(),
        ).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      await user.delete();
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
    try {
      await _users.doc(user.uid).delete();
    } catch (_) {}
  }
}
