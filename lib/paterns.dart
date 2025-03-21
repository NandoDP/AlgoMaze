import 'package:puzzle/actions.dart';

class Patern {
  final int niveau;
  final List<List<int>> tile;
  List<List<int>>? orangeTile;
  final int direction;
  final List<Move> buttons;
  final int steps;
  final List<int> diamant;
  final List<List<int>> star;
  final int timeRemaining;
  Patern({
    required this.niveau,
    required this.tile,
    this.orangeTile,
    required this.direction,
    required this.buttons,
    required this.steps,
    required this.diamant,
    required this.star,
    required this.timeRemaining,
  });

  Patern copyWith({
    int? niveau,
    List<List<int>>? tile,
    List<List<int>>? orangeTile,
    int? direction,
    List<Move>? buttons,
    int? steps,
    List<int>? diamant,
    List<List<int>>? star,
    int? timeRemaining,
  }) {
    return Patern(
      niveau: niveau ?? this.niveau,
      tile: tile ?? this.tile,
      orangeTile: orangeTile ?? this.orangeTile,
      direction: direction ?? this.direction,
      buttons: buttons ?? this.buttons,
      steps: steps ?? this.steps,
      diamant: diamant ?? this.diamant,
      star: star ?? this.star,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }

  @override
  String toString() {
    return 'Patern(niveau: $niveau, tile: $tile, orangeTile: $orangeTile, direction: $direction, buttons: $buttons, steps: $steps, diamant: $diamant, star: $star, timeRemaining: $timeRemaining)';
  }
}

List<Patern> paterns = [
  patern1,
  patern2,
  patern3,
  patern4,
];

Patern patern1 = Patern(
  niveau: 1,
  tile: [
    [5, 7],
    [6, 7],
    [7, 7],
    [8, 7],
    [9, 7],
    [10, 7],
  ],
  direction: 1,
  buttons: [Move.moveFoward, Move.repet],
  steps: 2,
  diamant: [5, 7],
  star: [[10, 7]],
  timeRemaining: 600,
);

Patern patern2 = Patern(
  niveau: 2,
  tile: [
    [13, 2],
    [12, 2],
    [12, 3],
    [11, 3],
    [11, 4],
    [10, 4],
    [10, 5],
    [9, 5],
    [9, 6],
    [8, 6],
    [8, 7],
    [7, 7],
    [7, 8],
    [6, 8],
    [6, 9],
    [5, 9],
    [5, 10],
    [4, 10],
  ],
  direction: 3,
  buttons: [Move.moveFoward, Move.rotatLeft, Move.rotatRight, Move.repet],
  steps: 5,
  diamant: [11, 3],
  star: [[4, 10]],
  timeRemaining: 900,
);

Patern patern3 = Patern(
  niveau: 3,
  tile: [
    [10, 2], [10, 1], //
    [9, 3], [9, 2], //
    [8, 4], [8, 3], //
    [7, 5], [7, 4], //
    [6, 6], [6, 5], //
    [5, 6], [5, 7], [5, 8], [5, 9], //
    [6, 9], [6, 10], //
    [7, 10], [7, 11], //
    [8, 11], [8, 12], //
    [9, 12], [9, 13], //
    [10, 13], [10, 14], //
  ],
  direction: 2,
  buttons: [Move.moveFoward, Move.rotatLeft, Move.rotatRight, Move.repet],
  steps: 5,
  // orangeTiles: [
  //   [4, 7],
  //   [4, 8]
  // ],
  diamant: [8, 11],
  // diamant: [9, 12],
  star: [[10, 14]],
  timeRemaining: 1200,
);

Patern patern4 = Patern(
  niveau: 4,
  tile: [
    [2, 8],
    [3, 8],
    [4, 8],
    [5, 8],
    [6, 8],
    [7, 8], [7, 9], [7, 10], [7, 11], [7, 12], [7, 13],
    [8, 8],
    [9, 8],
    [10, 8],
    [11, 8],
    [12, 8],
  ],
  direction: 4,
  buttons: [Move.moveFoward, Move.rotatLeft, Move.rotatRight, Move.repet],
  steps: 6,
  orangeTile: [
    [2, 8],
    [12, 8],
    [7, 13],
  ],
  diamant: [7, 13],
  star: [[2, 8], [12, 8]],
  timeRemaining: 1200,
);
