import 'package:flutter/material.dart';
import 'package:puzzle/actions.dart';

class Patern {
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
  Patern({
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

  Patern copyWith({
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
    return Patern(
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
    return 'Patern(niveau: $niveau, tile: $tile, orangeTile: $orangeTile, violetTile: $violetTile, direction: $direction, buttons: $buttons, steps0: $steps0, steps1: $steps1, diamant: $diamant, star: $star, timeRemaining: $timeRemaining)';
  }
}

List<Patern> paterns = [
  patern1,
  patern2,
  patern3,
  patern4,
  patern5,
  patern6,
  patern7,
  patern8,
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
  buttons: [Move.moveFoward, Move.repetStage0],
  steps0: 2,
  diamant: [5, 7],
  star: [
    [10, 7]
  ],
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
  buttons: [Move.moveFoward, Move.rotatLeft, Move.rotatRight, Move.repetStage0],
  steps0: 5,
  diamant: [11, 3],
  star: [
    [4, 10]
  ],
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
  buttons: [Move.moveFoward, Move.rotatLeft, Move.rotatRight, Move.repetStage0],
  steps0: 5,
  orangeTile: [
    [4, 7],
    [4, 8]
  ],
  diamant: [8, 11],
  star: [
    [10, 14]
  ],
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
    [7, 8],
    [7, 9],
    [7, 10],
    [7, 11],
    [7, 12],
    [7, 13],
    [8, 8],
    [9, 8],
    [10, 8],
    [11, 8],
    [12, 8],
  ],
  direction: 0,
  buttons: [
    Move.moveFoward,
    Move.rotatLeft,
    Move.rotatRight,
    Color(0xFF790382),
    // Colors.teal,
    Colors.orange,
    Move.repetStage0
  ],
  steps0: 6,
  orangeTile: [
    [2, 8],
    [12, 8],
    [7, 13],
  ],
  violetTile: [
    [7, 8]
  ],
  diamant: [7, 13],
  star: [
    [2, 8],
    [12, 8]
  ],
  timeRemaining: 1200,
);

Patern patern5 = Patern(
  niveau: 5,
  tile: [
    [6, 6],
    [7, 6],
    [8, 6],
    [9, 6], [10, 6],
    [9, 7],
    [9, 8],
    [9, 9],
    [8, 9],
    [7, 9],
    [6, 9],
    [6, 8],
    [6, 7],
  ],
  direction: 1,
  buttons: [
    Move.moveFoward,
    Move.rotatLeft,
    Move.rotatRight,
    Color(0xFF790382),
    Colors.orange,
    Move.repetStage0
  ],
  steps0: 4,
  violetTile: [
    [6, 6], [9, 6],
    [9, 9], [6, 9],
  ],
  diamant: [6, 6],
  star: [
    [9, 6], [10, 6],
    [9, 9], [6, 9],
  ],
  timeRemaining: 1200,
);

Patern patern6 = Patern(
  niveau: 6,
  tile: [
    [5, 5], [5, 6], [5, 7], [5, 8], [5, 9],
    [6, 5], [6, 6], [6, 7], [6, 8], [6, 9],
    [7, 5], [7, 6], [7, 7], [7, 8], [7, 9],
    [8, 5], [8, 6], [8, 7], [8, 8], [8, 9],
    [9, 5], [9, 6], [9, 7], [9, 8], [9, 9],
  ],
  direction: 1,
  buttons: [
    Move.moveFoward,
    Move.rotatLeft,
    Move.rotatRight,
    Color(0xFF790382),
    Colors.teal,
    Colors.orange,
    Move.repetStage0
  ],
  steps0: 4,
  orangeTile: [
    [5, 5], [5, 6], [5, 7], [5, 8], [5, 9],
    [6, 5], [6, 7], [6, 9],
    [7, 5], [7, 6], [7, 8], [7, 9],
    [8, 5], [8, 7], [8, 9],
    [9, 5], [9, 6], [9, 7], [9, 8], [9, 9],
  ],
  diamant: [7, 7],
  star: [
    [5, 5], [5, 6], [5, 7], [5, 8], [5, 9],
    [6, 5], [6, 7], [6, 9],
    [7, 5], [7, 6], [7, 8], [7, 9],
    [8, 5], [8, 7], [8, 9],
    [9, 5], [9, 6], [9, 7], [9, 8], [9, 6],
  ],
  timeRemaining: 1200,
);

Patern patern7 = Patern(
  niveau: 7,
  tile: [
    [2, 8],
    [3, 8],
    [4, 8],
    [5, 8],
    [6, 8],
    [7, 8],
    [7, 9],
    [7, 10],
    [7, 11],
    [7, 12],
    [7, 13],
    [8, 8],
    [9, 8],
    [10, 8],
    [11, 8],
    [12, 8],
  ],
  direction: 0,
  buttons: [
    Move.moveFoward,
    Move.rotatLeft,
    Move.rotatRight,
    Color(0xFF790382),
    // Colors.teal,
    Colors.orange,
    Move.repetStage0,
    Move.repetStage1,
  ],
  steps0: 3,
  steps1: 3,
  orangeTile: [
    [2, 8],
    [12, 8],
    [7, 13],
  ],
  violetTile: [
    [7, 8]
  ],
  diamant: [7, 13],
  star: [
    [2, 8],
    [12, 8]
  ],
  timeRemaining: 1200,
);

Patern patern8 = Patern(
  niveau: 8,
  tile: [
    [2, 6],
    [2, 7],
    [3, 7],
    [4, 7],
    [5, 7],
    [6, 7],
    [7, 7],
    [8, 7],
    [9, 7],
    [10, 7],
    [11, 7],
    [12, 7],
  ],
  direction: 3,
  buttons: [
    Move.moveFoward,
    Move.rotatLeft,
    Move.rotatRight,
    Color(0xFF790382),
    // Colors.teal,
    Colors.orange,
    Move.repetStage0,
    Move.repetStage1,
  ],
  steps0: 3,
  steps1: 3,
  orangeTile: [
    [2, 7],
    [6, 7],
    [7, 7],
    [8, 7],
    [9, 7],
    [10, 7],
    [11, 7],
    [12, 7],
  ],
  violetTile: [
    [2, 6],
    [3, 7],
    [4, 7],
    [5, 7],
  ],
  diamant: [12, 7],
  star: [
    [2, 6],
  ],
  timeRemaining: 1200,
);