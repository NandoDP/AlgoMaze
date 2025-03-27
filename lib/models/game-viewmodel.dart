import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/models/game-model.dart';
import 'package:puzzle/providers/navigation-service.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/widgets/game-over-dialog.dart';

class GameViewModel with ChangeNotifier implements GameActions {
  final PlayerStatsManager playerStatsManager;
  final PaternModel paternModel;
  late Timer _timer;

  // Game state variables
  List<List<dynamic>> actions1 = [];
  List<List<dynamic>> actions2 = [];
  late List<List<int>> turquoiseTiles;
  late List<List<int>> orangeTiles;
  late List<List<int>> violetTiles;
  late List<int> diamant;
  late List<List<int>> stars;
  late int _currentDirection;
  late int level;
  late List<PathStep> diamondPath;

  // Tracking collected items
  Set<List<int>> collectedStars = {};
  Set<List<int>> collectedStars2 = {};
  Set<List<int>> collectedVioletCase = {};
  Set<List<int>> collectedVioletCase2 = {};

  bool _isAnimating = false;

  // Timer variables
  late int _timeRemaining;
  bool _gameOver = false;
  bool _win = false;
  String _timeDisplay = "1:00:00";

  // // Player stats
  // PlayerStats? _playerStats;

  // Conffiti celebration
  late ConfettiController controllerCenterRight;
  late ConfettiController controllerCenterLeft;

  Color? _selectedColor;
  bool firstPassage = false;
  bool firstPassage2 = false;
  int consecutiveRepetStageCount = 0;

  // GameViewModel({required this.paternModel}) {
  //   _initializeGame();
  // }
  GameViewModel({required this.playerStatsManager, required this.paternModel}) {
    _initializeGame();
  }

  void _initializeGame() {
    _timeRemaining = paternModel.timeRemaining;
    turquoiseTiles = paternModel.tile;
    orangeTiles = paternModel.orangeTile ?? [];
    violetTiles = paternModel.violetTile ?? [];
    diamant = paternModel.diamant;
    stars = paternModel.star;
    _currentDirection = paternModel.direction;
    level = paternModel.niveau;
    diamondPath = [PathStep(diamant, _currentDirection)];

    controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 5));
    controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 5));

    _loadPlayerStats();

    startTimer();
  }

  // Future<void> _loadPlayerStats() async {
  //   _playerStats = await PlayerStatsManager.loadStats();
  //   _playerStats!.currentLevel = level;
  //   await PlayerStatsManager.saveStats(_playerStats!);
  //   notifyListeners();
  // }
  Future<void> _loadPlayerStats() async {
    final playerStats = playerStatsManager.currentStats;
    playerStats.currentLevel = level;
    await playerStatsManager.saveStats(playerStats);
    notifyListeners();
  }

  @override
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if ((collectedStars.length == stars.length) && !_isAnimating) {
        timer.cancel();
        controllerCenterLeft.play();
        controllerCenterRight.play();
        _win = true;
        // _handleWin();
      }

      if (_timeRemaining > 0) {
        _timeRemaining--;
        _updateTimeDisplay();
      } else {
        timer.cancel();
        _gameOver = true;
        // _handleGameOver();
      }
      notifyListeners();
    });
  }

  void _updateTimeDisplay() {
    int hours = _timeRemaining ~/ 3600;
    int minutes = (_timeRemaining % 3600) ~/ 60;
    int seconds = _timeRemaining % 60;
    _timeDisplay =
        "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void handleWin(BuildContext context) {
    final playerStats = playerStatsManager.currentStats;
    playerStats.levelCompleted(
        level, Duration(seconds: paternModel.timeRemaining - _timeRemaining));
    playerStatsManager.saveStats(playerStats);
    // Trigger win dialog or navigation
    DialogService.showWinDialog(
      context,
      onRestart: () {
        resetGame();
      },
      level: level,
      playerStats: playerStats,
      paternModel: paternModel,
      timeRemaining: _timeRemaining,
    );

    // notifyListeners();
  }

  void handleGameOver(BuildContext context) {
    // Trigger game over dialog or navigation
    DialogService.showGameOverDialog(
      context,
      onRestart: () {
        resetGame();
      },
    );
    // notifyListeners();
  }

  @override
  void addPointToPath(bool first) {
    (first ? actions1 : actions2).forEach((action) {
      final lastStep = diamondPath.last;
      final lastPosition = lastStep.position;
      if (!containsPosition(lastPosition, turquoiseTiles)) return;

      var currentDirection = lastStep.direction;
      Color lastPositionColor = containsPosition(lastPosition, orangeTiles)
          ? Colors.orange
          : (containsPosition(lastPosition, violetTiles) &&
                  !containsPosition(lastPosition, collectedVioletCase.toList()))
              ? Color(0xFF790382)
              : Colors.teal;

      bool move = (action[1] == Colors.grey || action[1] == lastPositionColor);

      if (containsPosition(lastPosition, violetTiles) &&
          !containsPosition(lastPosition, collectedVioletCase.toList())) {
        if (samePosition(lastPosition, paternModel.diamant)) {
          // On collecte uniquement si le diamant a déjà quitté sa position initiale
          // et qu'il y revient
          if (firstPassage2) {
            collectedVioletCase.add(lastPosition);
            firstPassage2 = true;
          }
        } else {
          // Pour les autres cases violettes, on les collecte normalement
          firstPassage2 = true;
          collectedVioletCase.add(lastPosition);
        }
      }
      notifyListeners();

      int initialPathLength = diamondPath.length; // 2

      if (collectedStars.length != stars.length) {
        if (action[0] == Move.moveFoward && move) {
          List<int> newPosition;
          switch (currentDirection) {
            case 0: // Up
              newPosition = [lastPosition[0], lastPosition[1] - 1];
              break;
            case 1: // Right
              newPosition = [lastPosition[0] + 1, lastPosition[1]];
              break;
            case 2: // Down
              newPosition = [lastPosition[0], lastPosition[1] + 1];
              break;
            case 3: // Left
              newPosition = [lastPosition[0] - 1, lastPosition[1]];
              break;
            default:
              newPosition = lastPosition;
          }

          diamondPath.add(PathStep(newPosition, currentDirection));
          consecutiveRepetStageCount = 0;
          for (var star in stars) {
            if (samePosition(newPosition, star) &&
                !collectedStars.contains(star)) {
              collectedStars.add(star);
            }
          }
          notifyListeners();
          if (!containsPosition(newPosition, turquoiseTiles)) return;
        } else if (action[0] == Move.rotatLeft && move) {
          final newDirection = (currentDirection + 3) % 4;
          diamondPath.add(PathStep(List.from(lastPosition), newDirection,
              isRotation: true));
          consecutiveRepetStageCount = 0;
          notifyListeners();
        } else if (action[0] == Move.rotatRight && move) {
          final newDirection = (currentDirection + 1) % 4;
          diamondPath.add(PathStep(List.from(lastPosition), newDirection,
              isRotation: true));
          consecutiveRepetStageCount = 0;
          notifyListeners();
        } else if (action[0] == Move.repetStage0 && move) {
          // if (diamondPath.length == initialPathLength) {
          consecutiveRepetStageCount++;
          notifyListeners();
          // Si plus de 2 répétitions sans progression
          if (consecutiveRepetStageCount >= 2) {
            alertRepetition();
            // Réinitialiser le compteur
            consecutiveRepetStageCount = 0;
            notifyListeners();
            return;
          }
          // }

          if (diamondPath.length > 100) return;
          addPointToPath(true);
          return;
        } else if (action[0] == Move.repetStage1 && move) {
          // if (diamondPath.length == initialPathLength) {
          consecutiveRepetStageCount++;
          // Si plus de 2 répétitions sans progression
          if (consecutiveRepetStageCount >= 2) {
            alertRepetition();
            // Réinitialiser le compteur
            consecutiveRepetStageCount = 0;
            notifyListeners();
            return;
          }
          // }

          notifyListeners();
          if (diamondPath.length > 100) return;
          addPointToPath(false);
          return;
        }
      }
    });
  }

  void alertRepetition() {
    showDialog(
      context: NavigationService.navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text('Avertissement'),
        content: Text(
            'Vous semblez répéter des actions sans progresser. Vérifiez votre algorithme.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
        ],
      ),
    );
  }

  @override
  void resetGame() {
    actions1.clear();
    actions2.clear();
    collectedStars.clear();
    collectedStars2.clear();
    collectedVioletCase.clear();
    collectedVioletCase2.clear();
    diamondPath = [PathStep(diamant, _currentDirection)];
    _selectedColor = null;
    _timeRemaining = paternModel.timeRemaining;
    _updateTimeDisplay();
    _isAnimating = false;
    _win = false;
    _gameOver = false;
    notifyListeners();
  }

  @override
  void undoLastAction() {
    if (actions2.isNotEmpty) {
      actions2.removeLast();
    } else if (actions1.isNotEmpty) {
      actions1.removeLast();
    }
    _selectedColor = null;
    notifyListeners();
  }

  void setColor(Color? color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setIsAnimatedValue(bool value) {
    _isAnimating = value;
    notifyListeners();
  }

  void setCurrentDirectionValue(int value) {
    _currentDirection = value;
    notifyListeners();
  }

  // Getters for view access
  List<List<dynamic>> get firstActions => actions1;
  List<List<dynamic>> get secondActions => actions2;
  int get timeRemaining => _timeRemaining;
  String get timeDisplay => _timeDisplay;
  bool get isAnimating => _isAnimating;
  Color? get selectedColor => _selectedColor;
  bool get gameOver => _gameOver;
  bool get win => _win;
  int get currentDirection => _currentDirection;
  // PlayerStats get playerStats => _playerStats!;

  // Other necessary methods and getters
}

bool containsPosition(List<int> position, List<List<int>> tiles) {
  for (var tile in tiles) {
    if (samePosition(position, tile)) {
      return true;
    }
  }
  return false;
}

bool samePosition(List<int> pos1, List<int> pos2) {
  return (pos1[0] == pos2[0]) && (pos1[1] == pos2[1]);
}
