import 'package:flutter/material.dart';

enum Move { rotatLeft, rotatRight, moveFoward, repetStage0, repetStage1 }

// Tablette: 926 x 600
// Phone: 807 x 383

IconData getIconData(Move action) {
  switch (action) {
    case Move.moveFoward:
      return Icons.arrow_upward;
    case Move.repetStage0:
      return Icons.exposure_zero_rounded;
    case Move.repetStage1:
      return Icons.one_x_mobiledata_rounded;
    case Move.rotatLeft:
      return Icons.arrow_back_rounded;
    case Move.rotatRight:
      return Icons.arrow_forward_rounded;
  }
}
