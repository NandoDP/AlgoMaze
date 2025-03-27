import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:puzzle/models/game-model.dart';
import 'package:puzzle/veiws/game-view.dart';
import 'package:puzzle/providers/navigation-service.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/veiws/home.dart';
import 'package:puzzle/paterns.dart';

class DialogService {
  static void showWinDialog(
    BuildContext context, {
    required int level,
    required VoidCallback onRestart,
    required PlayerStats playerStats,
    required PaternModel paternModel,
    required int timeRemaining,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E32).withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Félicitations 👑',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Niveaux complétés:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${playerStats.completedLevelsCount}/${paterns.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 10,
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 7.0,
                    animationDuration: 1000,
                    percent: playerStats.completedLevelsCount / paterns.length,
                    barRadius: const Radius.circular(5),
                    progressColor: Colors.teal,
                    backgroundColor: Colors.grey[800],
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Temps de jeu:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _timeDisplay(paternModel.timeRemaining - timeRemaining)!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Meilleur temps (niveau ${playerStats.bestTimeLevel}):',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      playerStats.formattedbestTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: level == paterns.length
                      ? null
                      : () {
                          onRestart();
                          NavigationService.goBack();
                          NavigationService.navigateReplacementTo(GameScreen(
                            paternModel: paterns[level],
                          ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CCAA),
                    foregroundColor: const Color(0xFF1A1A2E),
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40 / 2),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Suivant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                          onRestart();
                        NavigationService.goBack();
                        NavigationService.navigateReplacementTo(HomeScreen(
                          // playerStats: playerStats,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(120, 40),
                      ),
                      child: Text(
                        'Accueil',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        NavigationService.goBack();
                        // Navigator.of(context).pop();
                        onRestart();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(120, 40),
                      ),
                      child: Text(
                        'Rejouer',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showGameOverDialog(
    BuildContext context, {
    required VoidCallback onRestart,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Temps écoulé!', style: TextStyle(color: Colors.red)),
          content: Text('Vous avez perdu. Le temps imparti est écoulé.'),
          actions: <Widget>[
            TextButton(
              child: Text('Réessayer'),
              onPressed: () {
                NavigationService.goBack();
                onRestart();
              },
            ),
          ],
        );
      },
    );
  }

  static String? _timeDisplay(int timeRemaining) {
    int time = timeRemaining;
    int hours = time ~/ 3600;
    int minutes = (time % 3600) ~/ 60;
    int seconds = time % 60;
    String timeDisplay =
        "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    return timeDisplay;
  }
}