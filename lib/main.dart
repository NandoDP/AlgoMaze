import 'package:flutter/material.dart';
import 'package:puzzle/home.dart';
import 'package:puzzle/player-model.dart';

Future<void> main() async {
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
      home: HomeScreen(playerStats: playerStats),
    );
  }
}