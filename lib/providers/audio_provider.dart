import 'package:flutter/foundation.dart';
import '../utils/audio_utils.dart';

class AudioProvider with ChangeNotifier {
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  String? _currentPlayingPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;
  String? get currentPlayingPath => _currentPlayingPath;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackPosition => _playbackPosition;

  AudioProvider() {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await AudioUtils.initializeRecorder();
    await AudioUtils.initializePlayer();
  }

  Future<bool> startRecording() async {
    if (_isRecording || _isPlaying) return false;

    try {
      final recordingPath = await AudioUtils.startRecording();
      if (recordingPath != null) {
        _isRecording = true;
        _currentRecordingPath = recordingPath;
        _recordingDuration = Duration.zero;
        _startRecordingTimer();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur démarrage enregistrement: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final recordingPath = await AudioUtils.stopRecording();
      _isRecording = false;
      _stopRecordingTimer();
      notifyListeners();
      return recordingPath;
    } catch (e) {
      print('Erreur arrêt enregistrement: $e');
      return null;
    }
  }

  Future<bool> playAudio(String audioPath) async {
    if (_isRecording || _isPlaying) return false;

    try {
      final success = await AudioUtils.playAudio(audioPath);
      if (success) {
        _isPlaying = true;
        _currentPlayingPath = audioPath;
        _playbackPosition = Duration.zero;
        _startPlaybackTimer();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lecture audio: $e');
      return false;
    }
  }

  Future<void> stopPlaying() async {
    if (!_isPlaying) return;

    try {
      await AudioUtils.stopPlaying();
      _isPlaying = false;
      _currentPlayingPath = null;
      _playbackPosition = Duration.zero;
      _stopPlaybackTimer();
      notifyListeners();
    } catch (e) {
      print('Erreur arrêt lecture: $e');
    }
  }

  Future<Duration?> getAudioDuration(String audioPath) async {
    return await AudioUtils.getAudioDuration(audioPath);
  }

  void _startRecordingTimer() {
    // Dans une implémentation réelle, on utiliserait un Timer
    // pour mettre à jour la durée d'enregistrement en temps réel
  }

  void _stopRecordingTimer() {
    // Arrêter le timer d'enregistrement
  }

  void _startPlaybackTimer() {
    // Dans une implémentation réelle, on utiliserait un Timer
    // pour mettre à jour la position de lecture en temps réel
  }

  void _stopPlaybackTimer() {
    // Arrêter le timer de lecture
  }

  @override
  void dispose() {
    AudioUtils.dispose();
    super.dispose();
  }
}
