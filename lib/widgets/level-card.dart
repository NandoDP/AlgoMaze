import 'package:flutter/material.dart';
import 'package:puzzle/veiws/game-view.dart';
import 'package:puzzle/providers/navigation-service.dart';
// import 'package:puzzle/game-page.dart';
import 'package:puzzle/paterns.dart';

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isCompleted;

  const LevelCard({
    Key? key,
    required this.levelNumber,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        startLevel(context, levelNumber);
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isCompleted ? Color(0xFF00CBA9) : Color(0xFF4A4A5A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$levelNumber',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (isCompleted)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
            if (!isCompleted)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            SizedBox(height: 8),
            Text(
              isCompleted ? 'Terminé' : 'Jouer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startLevel(BuildContext context, int levelNumber) {
    NavigationService.navigateTo(GameScreen(
      paternModel: paterns[levelNumber - 1],
    ));
  }
}
