import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload d'un fichier audio
  Future<String?> uploadAudio(String filePath, String userId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Fichier audio non trouvé: $filePath');
        return null;
      }

      final fileName = '${_uuid.v4()}.aac';
      final ref = _storage
          .ref()
          .child(Constants.audioStoragePath)
          .child(userId)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }

      return null;
    } catch (e) {
      print('Erreur upload audio: $e');
      return null;
    }
  }

  // Upload d'une vidéo
  Future<String?> uploadVideo(String filePath, String userId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Fichier vidéo non trouvé: $filePath');
        return null;
      }

      final fileName = '${_uuid.v4()}.mp4';
      final ref = _storage
          .ref()
          .child(Constants.videoStoragePath)
          .child(userId)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }

      return null;
    } catch (e) {
      print('Erreur upload vidéo: $e');
      return null;
    }
  }

  // Upload d'une image
  Future<String?> uploadImage(String filePath, String userId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Fichier image non trouvé: $filePath');
        return null;
      }

      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child(Constants.imagesStoragePath)
          .child(userId)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }

      return null;
    } catch (e) {
      print('Erreur upload image: $e');
      return null;
    }
  }

  // Supprimer un fichier
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Erreur suppression fichier: $e');
      return false;
    }
  }

  // Obtenir la taille d'un fichier
  Future<int?> getFileSize(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      print('Erreur récupération taille fichier: $e');
      return null;
    }
  }

  // Obtenir les métadonnées d'un fichier
  Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('Erreur récupération métadonnées: $e');
      return null;
    }
  }

  // Lister les fichiers d'un utilisateur
  Future<List<String>> listUserFiles(String userId, String folder) async {
    try {
      final ref = _storage.ref().child(folder).child(userId);
      final result = await ref.listAll();

      final List<String> downloadUrls = [];
      for (final item in result.items) {
        try {
          final url = await item.getDownloadURL();
          downloadUrls.add(url);
        } catch (e) {
          print('Erreur récupération URL pour ${item.name}: $e');
        }
      }

      return downloadUrls;
    } catch (e) {
      print('Erreur listage fichiers: $e');
      return [];
    }
  }

  // Upload avec progress callback
  Future<String?> uploadFileWithProgress(
    String filePath,
    String userId,
    String folder,
    Function(double)? onProgress,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Fichier non trouvé: $filePath');
        return null;
      }

      final extension = filePath.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage.ref().child(folder).child(userId).child(fileName);

      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }

      return null;
    } catch (e) {
      print('Erreur upload avec progress: $e');
      return null;
    }
  }
}
