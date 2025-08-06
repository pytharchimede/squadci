import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  static final FlutterSoundPlayer _player = FlutterSoundPlayer();

  static bool _isRecorderInitialized = false;
  static bool _isPlayerInitialized = false;

  // Initialiser l'enregistreur
  static Future<bool> initializeRecorder() async {
    if (_isRecorderInitialized) return true;

    try {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      return true;
    } catch (e) {
      print('Erreur initialisation recorder: $e');
      return false;
    }
  }

  // Initialiser le lecteur
  static Future<bool> initializePlayer() async {
    if (_isPlayerInitialized) return true;

    try {
      await _player.openPlayer();
      _isPlayerInitialized = true;
      return true;
    } catch (e) {
      print('Erreur initialisation player: $e');
      return false;
    }
  }

  // Demander les permissions audio
  static Future<bool> requestAudioPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  // Commencer l'enregistrement
  static Future<String?> startRecording() async {
    if (!await requestAudioPermissions()) {
      return null;
    }

    if (!await initializeRecorder()) {
      return null;
    }

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        sampleRate: 16000,
        bitRate: 64000,
      );

      return filePath;
    } catch (e) {
      print('Erreur démarrage enregistrement: $e');
      return null;
    }
  }

  // Arrêter l'enregistrement
  static Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      return path;
    } catch (e) {
      print('Erreur arrêt enregistrement: $e');
      return null;
    }
  }

  // Jouer un audio
  static Future<bool> playAudio(String filePath) async {
    if (!await initializePlayer()) {
      return false;
    }

    try {
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.aacADTS,
      );
      return true;
    } catch (e) {
      print('Erreur lecture audio: $e');
      return false;
    }
  }

  // Arrêter la lecture
  static Future<void> stopPlaying() async {
    try {
      await _player.stopPlayer();
    } catch (e) {
      print('Erreur arrêt lecture: $e');
    }
  }

  // Obtenir la durée d'un fichier audio
  static Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      // Approximation basée sur la taille du fichier (pour AAC 64kbps)
      final fileSize = await file.length();
      final durationSeconds = (fileSize * 8) / 64000; // 64kbps

      return Duration(milliseconds: (durationSeconds * 1000).round());
    } catch (e) {
      print('Erreur calcul durée: $e');
      return null;
    }
  }

  // Compresser un fichier audio
  static Future<String?> compressAudio(String inputPath) async {
    try {
      final directory = await getTemporaryDirectory();
      final outputPath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Pour une compression simple, on copie juste le fichier
      // Dans une version plus avancée, on pourrait utiliser FFmpeg
      final inputFile = File(inputPath);
      await inputFile.copy(outputPath);

      return outputPath;
    } catch (e) {
      print('Erreur compression audio: $e');
      return null;
    }
  }

  // Nettoyer les ressources
  static Future<void> dispose() async {
    try {
      if (_isRecorderInitialized) {
        await _recorder.closeRecorder();
        _isRecorderInitialized = false;
      }
      if (_isPlayerInitialized) {
        await _player.closePlayer();
        _isPlayerInitialized = false;
      }
    } catch (e) {
      print('Erreur nettoyage ressources audio: $e');
    }
  }

  // Formater la durée audio
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
