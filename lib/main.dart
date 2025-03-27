import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/paterns.dart';
import 'package:puzzle/providers/navigation-service.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/veiws/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // final playerStats = await PlayerStatsManager.loadStats();

  // runApp(MyApp(playerStats: playerStats));
  final playerStatsManager = PlayerStatsManager();
  final PlayerStats playerStats = await playerStatsManager.loadStats();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerStatsManager>.value(value: playerStatsManager),
        ProxyProvider<PlayerStatsManager, GameViewModel>(
          update: (context, playerStatsManager, previousViewModel) {
            return GameViewModel(
              playerStatsManager: playerStatsManager,
              paternModel: paterns[playerStats.currentLevel - 1],
            );
          },
        ),
      ],
      child: MyApp(playerStats: playerStats),
    ),
  );
}

class MyApp extends StatelessWidget {
  PlayerStats playerStats;
  MyApp({super.key, required this.playerStats});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algo Maze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00CCAA),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        brightness: Brightness.dark,
      ),
      navigatorKey: NavigationService.navigatorKey,
      home: HomeScreen(),
      // home: HomeScreen(playerStats: playerStats),
    );
  }
}