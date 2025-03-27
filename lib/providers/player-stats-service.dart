import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerStats {
  int currentLevel;
  Set<int> completedLevels;
  Duration totalPlayTime;
  Duration bestTime;
  int bestTimeLevel;

  PlayerStats({
    this.currentLevel = 1,
    Set<int>? completedLevels,
    this.totalPlayTime = Duration.zero,
    this.bestTime = const Duration(hours: 999), // Valeur initiale
    this.bestTimeLevel = 0,
  }) : this.completedLevels = completedLevels ?? {};

  int get completedLevelsCount => completedLevels.length;

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'completedLevels': completedLevels.toList(),
      'totalPlayTime': totalPlayTime.inSeconds,
      'bestTime': bestTime.inSeconds,
      'bestTimeLevel': bestTimeLevel,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final Set<int> parsedCompletedLevels = Set<int>.from(
      (json['completedLevels'] ?? []).map(
        (level) => level is int ? level : int.parse(level.toString()),
      ),
    );
    return PlayerStats(
      currentLevel: json['currentLevel'] ?? 1,
      completedLevels: parsedCompletedLevels,
      totalPlayTime: Duration(seconds: json['totalPlayTime'] ?? 0),
      bestTime: Duration(
          seconds: json['bestTime'] ?? 999 * 3600), // 999 heures par défaut
      bestTimeLevel: json['bestTimeLevel'] ?? 0,
    );
  }

  String get formattedTotalPlayTime {
    final hours = totalPlayTime.inSeconds ~/ 3600;
    final minutes = (totalPlayTime.inSeconds % 3600) ~/ 60;
    final secondes = totalPlayTime.inSeconds % 60;
    return '${hours}h ${minutes}m ${secondes}s';
  }

  String get formattedbestTime {
    final hours = bestTime.inSeconds ~/ 3600;
    final minutes = (bestTime.inSeconds % 3600) ~/ 60;
    final secondes = bestTime.inSeconds % 60;
    return '${hours}h ${minutes}m ${secondes}s';
  }

  void levelCompleted(int level, Duration levelTime) {
    completedLevels.add(level);
    totalPlayTime += levelTime;

    if (levelTime < bestTime) {
      bestTime = levelTime;
      bestTimeLevel = level;
    }
  }

  void addPlayTime(Duration time) {
    totalPlayTime += time;
  }
}

class PlayerStatsManager {
  static const String _storageKey = 'player_stats';
  static PlayerStats? _cachedStats;
  static bool firstTime = false;

  // Charger les stats depuis le stockage local
  static Future<PlayerStats> loadStats() async {
    if (_cachedStats != null) {
      return _cachedStats!;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_storageKey);

    if (statsJson == null) {
      // Aucune donnée sauvegardée, créer un nouvel objet stats
      firstTime = true;
      _cachedStats = PlayerStats();
      return _cachedStats!;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(statsJson);
      _cachedStats = PlayerStats.fromJson(json);
      return _cachedStats!;
    } catch (e) {
      // En cas d'erreur, retourner des stats par défaut
      print('Erreur lors du chargement des stats: $e');
      _cachedStats = PlayerStats();
      return _cachedStats!;
    }
  }

  // Sauvegarder les stats dans le stockage local
  static Future<bool> saveStats(PlayerStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final String statsJson = jsonEncode(stats.toJson());
    // Mettre à jour le cache
    _cachedStats = stats; 
    return await prefs.setString(_storageKey, statsJson);
  }

  // Réinitialiser toutes les données du joueur
  static Future<bool> resetAllStats() async {
    try {
      // Réinitialiser le cache en mémoire
      _cachedStats = PlayerStats();

      // Supprimer les données de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      // Sauvegarder de nouvelles stats vides
      // return await saveStats(_cachedStats!);
      return true;
    } catch (e) {
      print('Erreur lors de la réinitialisation des stats: $e');
      return false;
    }
  }
}






// class PlayerStats {
//   int currentLevel;
//   List<LevelCompletion> completedLevels;

//   PlayerStats({
//     this.currentLevel = 1,
//     List<LevelCompletion>? completedLevels,
//   }) : completedLevels = completedLevels ?? [];

//   void levelCompleted(int level, Duration timeTaken) {
//     // Check if level already exists
//     var existingLevel = completedLevels.firstWhere(
//       (l) => l.level == level, 
//       orElse: () {
//         var newLevel = LevelCompletion(level: level, bestTime: timeTaken);
//         completedLevels.add(newLevel);
//         return newLevel;
//       }
//     );

//     // Update best time if current time is faster
//     if (timeTaken < existingLevel.bestTime) {
//       existingLevel.bestTime = timeTaken;
//     }
//   }
// }

// class LevelCompletion {
//   int level;
//   Duration bestTime;

//   LevelCompletion({
//     required this.level, 
//     required this.bestTime
//   });
// }

// class PlayerStatsManager {
//   static Future<PlayerStats> loadStats() async {
//     // Implement actual loading logic (e.g., from SharedPreferences or a database)
//     return PlayerStats();
//   }

//   static Future<void> saveStats(PlayerStats stats) async {
//     // Implement actual saving logic
//   }
// }
