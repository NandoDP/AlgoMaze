import 'package:flutter/material.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/paterns.dart';
import 'package:puzzle/widgets/level-card.dart';

class LevelSelectionList extends StatelessWidget {
  final PlayerStats playerStats;
  const LevelSelectionList({
    super.key,
    required this.playerStats,
  });
  @override
  Widget build(BuildContext context) {
    final totalLevels = paterns.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12),
      itemCount: totalLevels,
      itemBuilder: (context, index) {
        final levelNumber = index + 1;
        final isCompleted = playerStats.completedLevels.contains(levelNumber);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: LevelCard(
            levelNumber: levelNumber,
            isCompleted: isCompleted,
          ),
        );
      },
    );
  }
}