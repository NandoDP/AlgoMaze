import 'package:flutter/material.dart';

enum Move { rotatLeft, rotatRight, moveFoward, repet }

IconData getIconData(Move action) {
  switch (action) {
    case Move.moveFoward:
      return Icons.arrow_upward;
    case Move.repet:
      return Icons.circle_outlined;
    case Move.rotatLeft:
      return Icons.arrow_back_rounded;
    case Move.rotatRight:
      return Icons.arrow_forward_rounded;
  }
}
