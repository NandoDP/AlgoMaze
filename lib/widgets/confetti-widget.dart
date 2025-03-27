import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';

class Confettiwidget extends StatelessWidget {
  Confettiwidget({
    super.key,
    // required this.controllerCenterLeft,
    // required this.controllerCenterRight,
  });
  // ConfettiController controllerCenterRight;
  // ConfettiController controllerCenterLeft;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConfettiWidget(
          confettiController: viewModel.controllerCenterLeft,
          blastDirection: -pi / 3,
          maxBlastForce: 60,
          minBlastForce: 40,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.05,
          shouldLoop: false,
          colors: const [Colors.green, Colors.blue, Colors.pink],
          strokeWidth: 1,
          strokeColor: Colors.white,
        ),
        ConfettiWidget(
          confettiController: viewModel.controllerCenterRight,
          blastDirection: -2 * pi / 3,
          particleDrag: 0.05,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          maxBlastForce: 60,
          minBlastForce: 40,
          gravity: 0.05,
          shouldLoop: false,
          colors: const [Colors.green, Colors.blue, Colors.pink],
          strokeWidth: 1,
          strokeColor: Colors.white,
        ),
      ],
    );
  }
}
