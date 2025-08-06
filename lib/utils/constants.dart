class Constants {
  // App Info
  static const String appName = 'SQUAD CI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Application sociale ivoirienne';

  // Audio Settings
  static const int maxAudioDurationSeconds = 60;
  static const int audioSampleRate = 16000;
  static const String audioFormat = 'aac';

  // Video Settings
  static const int maxVideoDurationSeconds = 15;
  static const String videoQuality = '480p';
  static const int maxVideoSizeMB = 10;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String voiceStatusCollection = 'voice_status';
  static const String chatroomsCollection = 'chatrooms';
  static const String messagesSubcollection = 'messages';
  static const String miniStoriesCollection = 'mini_stories';

  // Storage Paths
  static const String audioStoragePath = 'audio';
  static const String videoStoragePath = 'videos';
  static const String imagesStoragePath = 'images';

  // Default Values
  static const List<String> defaultSalons = [
    'École',
    'Gbaka',
    'Quartier',
    'Boulot',
    'Sport',
    'Musique',
    'Général'
  ];

  static const List<String> defaultQuartiers = [
    'Cocody',
    'Plateau',
    'Adjamé',
    'Treichville',
    'Marcory',
    'Yopougon',
    'Abobo',
    'Port-Bouët',
    'Koumassi',
    'Attécoubé'
  ];

  // Challenges
  static const List<String> weeklysChallenges = [
    'Voix de gbaka du jour',
    'Défi nouchi de la semaine',
    'Histoire drôle du quartier',
    'Moment culturel ivoirien',
    'Expression du jour'
  ];
}
