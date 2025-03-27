// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:puzzle/MVVM/game-view.dart';
// import 'package:puzzle/MVVM/navigation-service.dart';

// // import 'package:puzzle/game-page.dart';
// import 'package:puzzle/paterns.dart';
// import 'package:puzzle/widgets/grid-paint.dart';
// import 'package:puzzle/widgets/level-selection-list.dart';
// import 'package:puzzle/widgets/stats-panel.dart';

// import 'dart:async';
// import 'package:confetti/confetti.dart';
// import 'package:puzzle/MVVM/game-model.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter/material.dart';
// import 'package:puzzle/MVVM/navigation-service.dart';
// import 'package:puzzle/MVVM/player-stats-service.dart';
// import 'package:puzzle/home.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   final playerStats = await PlayerStatsManager.loadStats();

//   runApp(MyApp(playerStats: playerStats));
// }

// class MyApp extends StatelessWidget {
//   PlayerStats playerStats;
//   MyApp({super.key, required this.playerStats});

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
//       home: HomeScreen(playerStats: playerStats),
//     );
//   }
// }


// class PlayerStats {
//   int currentLevel;
//   Set<int> completedLevels;
//   Duration totalPlayTime;
//   Duration bestTime;
//   int bestTimeLevel;

//   PlayerStats({
//     this.currentLevel = 1,
//     Set<int>? completedLevels,
//     this.totalPlayTime = Duration.zero,
//     this.bestTime = const Duration(hours: 999), // Valeur initiale
//     this.bestTimeLevel = 0,
//   }) : this.completedLevels = completedLevels ?? {};

//   int get completedLevelsCount => completedLevels.length;

//   Map<String, dynamic> toJson() {
//     return {
//       'currentLevel': currentLevel,
//       'completedLevels': completedLevels.toList(),
//       'totalPlayTime': totalPlayTime.inSeconds,
//       'bestTime': bestTime.inSeconds,
//       'bestTimeLevel': bestTimeLevel,
//     };
//   }

//   factory PlayerStats.fromJson(Map<String, dynamic> json) {
//     final Set<int> parsedCompletedLevels = Set<int>.from(
//       (json['completedLevels'] ?? []).map(
//         (level) => level is int ? level : int.parse(level.toString()),
//       ),
//     );
//     return PlayerStats(
//       currentLevel: json['currentLevel'] ?? 1,
//       completedLevels: parsedCompletedLevels,
//       totalPlayTime: Duration(seconds: json['totalPlayTime'] ?? 0),
//       bestTime: Duration(
//           seconds: json['bestTime'] ?? 999 * 3600), // 999 heures par défaut
//       bestTimeLevel: json['bestTimeLevel'] ?? 0,
//     );
//   }

//   String get formattedTotalPlayTime {
//     final hours = totalPlayTime.inSeconds ~/ 3600;
//     final minutes = (totalPlayTime.inSeconds % 3600) ~/ 60;
//     final secondes = totalPlayTime.inSeconds % 60;
//     return '${hours}h ${minutes}m ${secondes}s';
//   }

//   String get formattedbestTime {
//     final hours = bestTime.inSeconds ~/ 3600;
//     final minutes = (bestTime.inSeconds % 3600) ~/ 60;
//     final secondes = bestTime.inSeconds % 60;
//     return '${hours}h ${minutes}m ${secondes}s';
//   }

//   void levelCompleted(int level, Duration levelTime) {
//     completedLevels.add(level);
//     totalPlayTime += levelTime;

//     if (levelTime < bestTime) {
//       bestTime = levelTime;
//       bestTimeLevel = level;
//     }
//   }

//   void addPlayTime(Duration time) {
//     totalPlayTime += time;
//   }
// }

// class PlayerStatsManager {
//   static const String _storageKey = 'player_stats';
//   static PlayerStats? _cachedStats;
//   static bool firstTime = false;

//   // Charger les stats depuis le stockage local
//   static Future<PlayerStats> loadStats() async {
//     if (_cachedStats != null) {
//       return _cachedStats!;
//     }

//     final prefs = await SharedPreferences.getInstance();
//     final String? statsJson = prefs.getString(_storageKey);

//     if (statsJson == null) {
//       // Aucune donnée sauvegardée, créer un nouvel objet stats
//       firstTime = true;
//       _cachedStats = PlayerStats();
//       return _cachedStats!;
//     }

//     try {
//       final Map<String, dynamic> json = jsonDecode(statsJson);
//       _cachedStats = PlayerStats.fromJson(json);
//       return _cachedStats!;
//     } catch (e) {
//       // En cas d'erreur, retourner des stats par défaut
//       print('Erreur lors du chargement des stats: $e');
//       _cachedStats = PlayerStats();
//       return _cachedStats!;
//     }
//   }

//   // Sauvegarder les stats dans le stockage local
//   static Future<bool> saveStats(PlayerStats stats) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String statsJson = jsonEncode(stats.toJson());
//     // Mettre à jour le cache
//     _cachedStats = stats; 
//     return await prefs.setString(_storageKey, statsJson);
//   }

//   // Réinitialiser toutes les données du joueur
//   static Future<bool> resetAllStats() async {
//     try {
//       // Réinitialiser le cache en mémoire
//       _cachedStats = PlayerStats();

//       // Supprimer les données de SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_storageKey);

//       // Sauvegarder de nouvelles stats vides
//       // return await saveStats(_cachedStats!);
//       return true;
//     } catch (e) {
//       print('Erreur lors de la réinitialisation des stats: $e');
//       return false;
//     }
//   }
// }

// class GameViewModel with ChangeNotifier implements GameActions {
//   final PaternModel paternModel;
//   late Timer _timer;

//   // Game state variables
//   List<List<dynamic>> actions1 = [];
//   List<List<dynamic>> actions2 = [];
//   late List<List<int>> turquoiseTiles;
//   late List<List<int>> orangeTiles;
//   late List<List<int>> violetTiles;
//   late List<int> diamant;
//   late List<List<int>> stars;
//   late int _currentDirection;
//   late int level;
//   late List<PathStep> diamondPath;

//   // Tracking collected items
//   Set<List<int>> collectedStars = {};
//   Set<List<int>> collectedStars2 = {};
//   Set<List<int>> collectedVioletCase = {};
//   Set<List<int>> collectedVioletCase2 = {};

//   bool _isAnimating = false;

//   // Timer variables
//   late int _timeRemaining;
//   bool _gameOver = false;
//   bool _win = false;
//   String _timeDisplay = "1:00:00";

//   // Player stats
//   PlayerStats? _playerStats;

//   // Conffiti celebration
//   late ConfettiController controllerCenterRight;
//   late ConfettiController controllerCenterLeft;

//   Color? _selectedColor;
//   bool firstPassage = false;
//   bool firstPassage2 = false;

//   GameViewModel({required this.paternModel}) {
//     _initializeGame();
//   }

//   void _initializeGame() {
//     _timeRemaining = paternModel.timeRemaining;
//     turquoiseTiles = paternModel.tile;
//     orangeTiles = paternModel.orangeTile ?? [];
//     violetTiles = paternModel.violetTile ?? [];
//     diamant = paternModel.diamant;
//     stars = paternModel.star;
//     _currentDirection = paternModel.direction;
//     level = paternModel.niveau;
//     diamondPath = [PathStep(diamant, _currentDirection)];

//     controllerCenterLeft =
//         ConfettiController(duration: const Duration(seconds: 5));
//     controllerCenterRight =
//         ConfettiController(duration: const Duration(seconds: 5));

//     _loadPlayerStats();

//     startTimer();
//   }

//   Future<void> _loadPlayerStats() async {
//     _playerStats = await PlayerStatsManager.loadStats();
//     _playerStats!.currentLevel = level;
//     await PlayerStatsManager.saveStats(_playerStats!);
//     notifyListeners();
//   }

//   @override
//   void resetGame() {
//     actions1.clear();
//     actions2.clear();
//     collectedStars.clear();
//     collectedStars2.clear();
//     collectedVioletCase.clear();
//     collectedVioletCase2.clear();
//     diamondPath = [PathStep(diamant, _currentDirection)];
//     _selectedColor = null;
//     _timeRemaining = paternModel.timeRemaining;
//     // _updateTimeDisplay();
//     _isAnimating = false;
//     _win = false;
//     _gameOver = false;
//     notifyListeners();
//   }

//   // Getters for view access
//   PlayerStats get playerStats => _playerStats!;

//   // Other necessary methods and getters
// }


// class HomeScreen extends StatefulWidget {
//   PlayerStats playerStats;
//   HomeScreen({
//     super.key,
//     required this.playerStats,
//   });

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // PlayerStats? _playerStats;
//   bool firstTime = true;

//   @override
//   Widget build(BuildContext context) {
//     // Get screen size
//     final Size screenSize = MediaQuery.of(context).size;
//     final bool isSmallScreen = screenSize.width < 360;
//     final bool isLargeScreen = screenSize.width > 600;

//     // Responsive dimensions
//     final double logoSize = isSmallScreen ? 45 : (isLargeScreen ? 80 : 56);
//     final double titleSize = isSmallScreen ? 28 : (isLargeScreen ? 40 : 32);
//     final double subtitleSize = isSmallScreen ? 12 : (isLargeScreen ? 18 : 14);
//     final double buttonWidth =
//         isSmallScreen ? 100 : (isLargeScreen ? 180 : 120);
//     final double buttonHeight = isSmallScreen ? 40 : (isLargeScreen ? 60 : 50);
//     final double buttonTextSize =
//         isSmallScreen ? 16 : (isLargeScreen ? 22 : 18);
//     final double topPadding = screenSize.height * 0.08;
//     final double spacing = screenSize.height * 0.03;
//     final viewModel = Provider.of<GameViewModel>(context);

//     return Scaffold(
//       body: ChangeNotifierProvider.value(
//         value: viewModel,
//         child: Consumer<GameViewModel>(
//           builder: (context, viewModel, child) {
//             // Votre logique de construction de l'interface
//             return Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
//                 ),
//               ),
//               child: SafeArea(
//                 child: Stack(
//                   children: [
//                     CustomPaint(
//                       size: Size(screenSize.width, screenSize.height),
//                       painter: GridPainter(),
//                     ),
//                     SingleChildScrollView(
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: screenSize.height,
//                           maxWidth: screenSize.width,
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: screenSize.width * 0.05),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               SizedBox(height: topPadding),

//                               // Title
//                               Text(
//                                 'CODE PATH',
//                                 style: TextStyle(
//                                   fontSize: titleSize,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF00CCAA),
//                                   shadows: const [
//                                     Shadow(
//                                       blurRadius: 5.0,
//                                       color: Colors.black45,
//                                       offset: Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               Text(
//                                 'Apprendre à programmer en s\'amusant',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: subtitleSize,
//                                   color: Colors.grey,
//                                 ),
//                               ),

//                               SizedBox(height: spacing * 2),

//                               // Game logo
//                               Container(
//                                 width: logoSize,
//                                 height: logoSize,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF00CCAA),
//                                   borderRadius:
//                                       BorderRadius.circular(logoSize * 0.09),
//                                 ),
//                                 child: Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     // Diamond shape
//                                     Transform.rotate(
//                                       angle: 45 * 3.14159 / 180,
//                                       child: Container(
//                                         width: logoSize * 0.7,
//                                         height: logoSize * 0.7,
//                                         color: const Color(0xFF1A1A2E),
//                                       ),
//                                     ),

//                                     // Center dot
//                                     Container(
//                                       width: logoSize * 0.18,
//                                       height: logoSize * 0.18,
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               SizedBox(height: spacing * 2),

//                               // Play button
//                               ElevatedButton(
//                                 onPressed: () {
//                                   NavigationService.navigateTo(GameScreen(
//                                     paternModel: paterns[
//                                         viewModel.playerStats.currentLevel - 1],
//                                   ));
//                                   // Navigator.push(
//                                   //   context,
//                                   //   MaterialPageRoute(
//                                   //     builder: (context) => GameScreen(
//                                   //       paternModel:
//                                   //           paterns[_playerStats!.currentLevel - 1],
//                                   //     ),
//                                   //   ),
//                                   // );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF00CCAA),
//                                   foregroundColor: const Color(0xFF1A1A2E),
//                                   minimumSize: Size(buttonWidth, buttonHeight),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(buttonHeight / 2),
//                                   ),
//                                   elevation: 5,
//                                 ),
//                                 child: Text(
//                                   firstTime ? 'Commencer' : 'Continuer',
//                                   style: TextStyle(
//                                     fontSize: buttonTextSize,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: spacing),

//                               ElevatedButton(
//                                 onPressed: () {
//                                   showLevelSelectionModal(context, viewModel);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF444444),
//                                   foregroundColor: Colors.white,
//                                   minimumSize: Size(buttonWidth, buttonHeight),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.circular(buttonHeight / 2),
//                                   ),
//                                   elevation: 5,
//                                 ),
//                                 child: Text(
//                                   'Nouvelle Partie',
//                                   style: TextStyle(
//                                     fontSize: buttonTextSize,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: 35),
//                               StatsPanel(
//                                 isSmallScreen: isSmallScreen,
//                                 isLargeScreen: isLargeScreen,
//                                 playerStats: viewModel.playerStats,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void showLevelSelectionModal(BuildContext context, GameViewModel viewModel) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Color(0xFF1E1E2E),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.4,
//           padding: EdgeInsets.symmetric(vertical: 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   'Sélectionner un niveau',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: LevelSelectionList(
//                   playerStats: viewModel.playerStats,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
