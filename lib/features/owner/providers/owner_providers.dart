import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/location/geo_utils.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/ground_repository.dart';
import '../data/owner_repository.dart';
import '../data/storage_service.dart';
import '../domain/ground.dart';

final ownerRegistrationControllerProvider =
    AsyncNotifierProvider<OwnerRegistrationController, void>(
  OwnerRegistrationController.new,
);

class OwnerRegistrationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(OwnerRegistrationData data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(ownerRepositoryProvider).register(data),
    );
  }
}

final ownerResubmitControllerProvider =
    AsyncNotifierProvider<OwnerResubmitController, void>(
  OwnerResubmitController.new,
);

class OwnerResubmitController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(OwnerRegistrationData data) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) throw StateError('Not signed in');
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(ownerRepositoryProvider).resubmitDocuments(uid: uid, data: data),
    );
  }
}

final groundSaveControllerProvider =
    AsyncNotifierProvider<GroundSaveController, void>(
  GroundSaveController.new,
);

class GroundSaveController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save({
    required Ground ground,
    required bool isNew,
    required List<XFile> newImages,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(groundRepositoryProvider);
      final geoGround = ground.copyWith(
        geohash: GeoUtils.encodeGeohash(ground.latitude, ground.longitude),
      );
      await repository.saveGround(geoGround, isNew: isNew);

      if (newImages.isEmpty) return;
      final uploaded = await ref.read(storageServiceProvider).uploadImages(
            folderPath: ref
                .read(storageServiceProvider)
                .groundImagesPath(ground.id),
            files: newImages,
          );
      await repository.saveGround(
        geoGround.copyWith(imageUrls: [...ground.imageUrls, ...uploaded]),
        isNew: false,
      );
    });
  }
}

final groundDeleteControllerProvider =
    AsyncNotifierProvider<GroundDeleteController, void>(
  GroundDeleteController.new,
);

class GroundDeleteController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> delete(String groundId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(groundRepositoryProvider).deleteGround(groundId),
    );
  }
}
