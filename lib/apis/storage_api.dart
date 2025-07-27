import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sboom_projlogging/constants/appwrite_constants.dart';
import 'package:sboom_projlogging/core/providers.dart';

final StorageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
});

abstract class IStorageAPI {
  Future<String> uploadMedia(XFile file);
}

class StorageAPI implements IStorageAPI {
  final Storage _storage;
  StorageAPI({required Storage storage}) : _storage = storage, super();

  @override
  Future<String> uploadMedia(XFile file) async {
    if (kIsWeb) {
      // On web, always use readAsBytes
      final uint8list = await file.readAsBytes();

      final uploadedImage = await _storage.createFile(
        bucketId: AppwriteConstants.quillMediaBucket,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: uint8list, filename: file.name),
      );

      final url = AppwriteConstants.imageUrl(uploadedImage.$id);
      return url;
    } else {
      // On mobile/desktop, use the file path
      final uploadedImage = await _storage.createFile(
        bucketId: AppwriteConstants.quillMediaBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );

      final url = AppwriteConstants.imageUrl(uploadedImage.$id);
      return url;
    }
  }
}
