import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/ground.dart';

class GroundRepository {
  const GroundRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _grounds =>
      _firestore.collection(AppConstants.groundsCollection);

  Stream<List<Ground>> watchMyGrounds(String ownerId) {
    return _grounds.where('ownerId', isEqualTo: ownerId).snapshots().map((snapshot) {
      final grounds = snapshot.docs.map(Ground.fromFirestore).toList();
      grounds.sort((a, b) => a.name.compareTo(b.name));
      return grounds;
    });
  }

  Future<Ground?> getGround(String groundId) async {
    final snapshot = await _grounds.doc(groundId).get();
    if (!snapshot.exists) return null;
    return Ground.fromFirestore(snapshot);
  }

  Future<void> saveGround(Ground ground, {required bool isNew}) async {
    final data = ground.toMap()..remove('updatedAt');
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _grounds.doc(ground.id).set(data);
    } else {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _grounds.doc(ground.id).update(data);
    }
  }

  Future<void> deleteGround(String groundId) => _grounds.doc(groundId).delete();

  Future<void> setActive(String groundId, bool isActive) {
    return _grounds.doc(groundId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final groundRepositoryProvider = Provider<GroundRepository>((ref) {
  return GroundRepository(FirebaseFirestore.instance);
});

final groundDetailProvider = FutureProvider.family<Ground?, String>((ref, id) {
  return ref.watch(groundRepositoryProvider).getGround(id);
});

final myGroundsProvider = StreamProvider<List<Ground>>((ref) {
  final ownerId = ref.watch(currentUserProvider)?.uid;
  if (ownerId == null) return Stream.value([]);
  return ref.watch(groundRepositoryProvider).watchMyGrounds(ownerId);
});
