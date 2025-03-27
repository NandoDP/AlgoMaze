
class PaternModel {
  final int niveau;
  final List<List<int>> tile;
  List<List<int>>? orangeTile;
  List<List<int>>? violetTile;
  final int direction;
  final List<dynamic> buttons;
  final int steps0;
  int? steps1;
  final List<int> diamant;
  final List<List<int>> star;
  final int timeRemaining;
  PaternModel({
    required this.niveau,
    required this.tile,
    this.orangeTile,
    this.violetTile,
    required this.direction,
    required this.buttons,
    required this.steps0,
    this.steps1,
    required this.diamant,
    required this.star,
    required this.timeRemaining,
  });

  PaternModel copyWith({
    int? niveau,
    List<List<int>>? tile,
    List<List<int>>? orangeTile,
    List<List<int>>? violetTile,
    int? direction,
    List<dynamic>? buttons,
    int? steps0,
    int? steps1,
    List<int>? diamant,
    List<List<int>>? star,
    int? timeRemaining,
  }) {
    return PaternModel(
      niveau: niveau ?? this.niveau,
      tile: tile ?? this.tile,
      orangeTile: orangeTile ?? this.orangeTile,
      violetTile: violetTile ?? this.violetTile,
      direction: direction ?? this.direction,
      buttons: buttons ?? this.buttons,
      steps0: steps0 ?? this.steps0,
      steps1: steps1 ?? this.steps1,
      diamant: diamant ?? this.diamant,
      star: star ?? this.star,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }

  @override
  String toString() {
    return 'PaternModel(niveau: $niveau, tile: $tile, orangeTile: $orangeTile, violetTile: $violetTile, direction: $direction, buttons: $buttons, steps0: $steps0, steps1: $steps1, diamant: $diamant, star: $star, timeRemaining: $timeRemaining)';
  }
}

// Path step représente chaque mouvement ou rotation dans le jeu
class PathStep {
  final List<int> position;
  final int direction;
  final bool isRotation;

  PathStep(this.position, this.direction, {this.isRotation = false});
}

// Enum pour différents types de mouvements
enum Move {
  moveFoward,
  rotatLeft,
  rotatRight,
  repetStage0,
  repetStage1
}

// Interface pour les actions du jeu
abstract class GameActions {
  void addPointToPath(bool first);
  void startTimer();
  void resetGame();
  void undoLastAction();
}
