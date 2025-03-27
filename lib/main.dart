import 'package:flutter/material.dart';
import 'package:puzzle/providers/navigation-service.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/veiws/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final playerStats = await PlayerStatsManager.loadStats();

  runApp(MyApp(playerStats: playerStats));
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
      home: HomeScreen(playerStats: playerStats),
    );
  }
}