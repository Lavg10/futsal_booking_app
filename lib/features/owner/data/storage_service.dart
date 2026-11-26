import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';

class StorageService {
  const StorageService(this._storage, this._uuid);

  final FirebaseStorage _storage;
  final Uuid _uuid;

  Future<String> uploadImage({
    required String folderPath,
    required XFile file,
    String? fileName,
  }) async {
    final name = fileName ?? '${_uuid.v4()}.jpg';
    final reference = _storage.ref().child(folderPath).child(name);
    final bytes = await File(file.path).readAsBytes();
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final snapshot = await reference.putData(bytes, metadata);
    return snapshot.ref.getDownloadURL();
  }

  Future<List<String>> uploadImages({
    required String folderPath,
    required List<XFile> files,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      urls.add(await uploadImage(folderPath: folderPath, file: file));
    }
    return urls;
  }

  String ownerDocumentPath(String uid, String type) {
    return '${AppConstants.ownerDocumentsPath}/$uid';
  }

  String groundImagesPath(String groundId) {
    return '${AppConstants.groundImagesPath}/$groundId';
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance, const Uuid());
});
