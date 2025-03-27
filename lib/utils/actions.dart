import 'package:flutter/material.dart';
import 'package:puzzle/models/game-model.dart';

// enum Move { rotatLeft, rotatRight, moveFoward, repetStage0, repetStage1 }

// Tablette: 926 x 600
// Phone: 807 x 383

IconData getIconData(Move action) {
  switch (action) {
    case Move.moveFoward:
      return Icons.arrow_upward;
    case Move.repetStage0:
      return Icons.repeat;
    case Move.repetStage1:
      return Icons.repeat_one;
    case Move.rotatLeft:
      return Icons.arrow_back_rounded;
    case Move.rotatRight:
      return Icons.arrow_forward_rounded;
  }
}
