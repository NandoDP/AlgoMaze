import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';

class Timerlevelwidget extends StatelessWidget {
  const Timerlevelwidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.timeDisplay,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: viewModel.timeRemaining < 300 ? Colors.red : Colors.white70,
                ),
              ),
              Text(
                "Niveau ${viewModel.level}",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}