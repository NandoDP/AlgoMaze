// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:async';

// // Existing imports remain the same

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   final playerStatsManager = PlayerStatsManager();
//   final PlayerStats playerStats = await playerStatsManager.loadStats();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider<PlayerStatsManager>.value(value: playerStatsManager),
//         ProxyProvider<PlayerStatsManager, GameViewModel>(
//           update: (context, playerStatsManager, previousViewModel) {
//             return GameViewModel(
//               playerStatsManager: playerStatsManager,
//               paternModel: paterns[playerStats.currentLevel - 1],
//             );
//           },
//         ),
//       ],
//       child: MyApp(playerStats: playerStats),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final PlayerStats playerStats;
  
//   const MyApp({Key? key, required this.playerStats}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Algo Maze',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF00CCAA),
//         scaffoldBackgroundColor: const Color(0xFF1A1A2E),
//         brightness: Brightness.dark,
//       ),
//       navigatorKey: NavigationService.navigatorKey,
//       home: HomeScreen(),
//     );
//   }
// }

// class PlayerStatsManager extends ChangeNotifier {
//   static const String _storageKey = 'player_stats';
//   PlayerStats? _cachedStats;
//   bool firstTime = false;

//   Future<PlayerStats> loadStats() async {
//     if (_cachedStats != null) return _cachedStats!;

//     final prefs = await SharedPreferences.getInstance();
//     final String? statsJson = prefs.getString(_storageKey);

//     if (statsJson == null) {
//       firstTime = true;
//       _cachedStats = PlayerStats();
//       return _cachedStats!;
//     }

//     try {
//       final Map<String, dynamic> json = jsonDecode(statsJson);
//       _cachedStats = PlayerStats.fromJson(json);
//       return _cachedStats!;
//     } catch (e) {
//       print('Erreur lors du chargement des stats: $e');
//       _cachedStats = PlayerStats();
//       return _cachedStats!;
//     }
//   }

//   Future<bool> saveStats(PlayerStats stats) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String statsJson = jsonEncode(stats.toJson());
//     _cachedStats = stats;
//     notifyListeners();
//     return await prefs.setString(_storageKey, statsJson);
//   }

//   Future<bool> resetAllStats() async {
//     try {
//       _cachedStats = PlayerStats();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_storageKey);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       print('Erreur lors de la réinitialisation des stats: $e');
//       return false;
//     }
//   }

//   PlayerStats get currentStats => _cachedStats ?? PlayerStats();
// }

// class GameViewModel extends ChangeNotifier {
//   final PlayerStatsManager playerStatsManager;
//   final PaternModel paternModel;

//   // Existing game state variables...

//   GameViewModel({
//     required this.playerStatsManager, 
//     required this.paternModel
//   }) {
//     _initializeGame();
//   }

//   void _initializeGame() {
//     // Existing initialization logic
//     _loadPlayerStats();
//   }

//   Future<void> _loadPlayerStats() async {
//     final playerStats = playerStatsManager.currentStats;
//     playerStats.currentLevel = level;
//     await playerStatsManager.saveStats(playerStats);
//     notifyListeners();
//   }

//   // Rest of the existing GameViewModel methods...
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final playerStatsManager = Provider.of<PlayerStatsManager>(context);
//     final gameViewModel = Provider.of<GameViewModel>(context);
//     final Size screenSize = MediaQuery.of(context).size;

//     // Existing screen logic remains the same, but use playerStatsManager.currentStats
//     // instead of directly accessing playerStats
//     return Scaffold(
//       body: Container(
//         // Existing container and child widgets
//         child: Column(
//           children: [
//             // Use playerStatsManager.currentStats
//             StatsPanel(
//               playerStats: playerStatsManager.currentStats,
//               // Other parameters...
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Rest of the existing code...