import 'package:puzzle/actions.dart';

const Map<String, dynamic> patern1 = {
  'niveau': 1, 
  'turquoiseTiles': [
    [5, 7], [6, 7], [7, 7], [8, 7], [9, 7], 
  ],
  'direction': 1,
  'buttons': [Move.moveFoward, Move.repet],
  'number': 2,
  'diamant': [5, 7],
  'star': [10, 7],
};

const Map<String, dynamic> patern3 = {
  'niveau': 3, 
  'turquoiseTiles': [
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
  'direction': 2,
  'buttons': [Move.moveFoward, Move.rotatLeft, Move.rotatRight, Move.repet],
  'steps': 5,
  'orangeTiles': [
    [4, 7],
    [4, 8]
  ],
  'diamant': [9, 12],
  'star': [10, 14],
};
