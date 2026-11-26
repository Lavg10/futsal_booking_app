import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/admin_repository.dart';
import '../../owner/domain/owner_application.dart';

final ownerApplicationDetailProvider =
    FutureProvider.family<OwnerApplication?, String>((ref, uid) {
  return ref.watch(adminRepositoryProvider).getApplication(uid);
});

final adminReviewControllerProvider =
    AsyncNotifierProvider<AdminReviewController, void>(
  AdminReviewController.new,
);

class AdminReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> approve(OwnerApplication application) async {
    final adminUid = ref.read(currentUserProvider)?.uid;
    if (adminUid == null) throw StateError('Not signed in');
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .approveApplication(application: application, adminUid: adminUid),
    );
  }

  Future<void> reject({required String uid, required String reason}) async {
    final adminUid = ref.read(currentUserProvider)?.uid;
    if (adminUid == null) throw StateError('Not signed in');
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).rejectApplication(
            uid: uid,
            reason: reason,
            adminUid: adminUid,
          ),
    );
  }
}
