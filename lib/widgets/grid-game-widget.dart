import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';

class Gridgamewidget extends StatelessWidget {
  const Gridgamewidget({super.key});
  final int gridSize = 16;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade800, width: 1),
            ),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: 1.0,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ gridSize;
                final col = index % gridSize;

                // Type de cellule
                Color tileColor = Colors.transparent;
                Widget tileContent = SizedBox();

                for (var pos in viewModel.turquoiseTiles) {
                  if (samePosition(pos, [col, row])) {
                    tileColor = Colors.teal;
                  }
                }

                // Placer les etoiles
                for (var star in viewModel.stars) {
                  if (samePosition(star, [col, row]) &&
                      !viewModel.collectedStars2.contains(star)) {
                    // tileColor = Colors.teal;
                    tileContent = Icon(
                      Icons.star,
                      color: Colors.black,
                      size: constraints.maxWidth / gridSize * 0.5,
                    );
                  }
                }

                // Diamant
                if (samePosition(viewModel.diamant, [col, row])) {
                  // Vert s'il collecte une etoile, turquoise s'il est bien positionné et rouge sinon
                  if (containsPosition([col, row], viewModel.stars)) {
                    tileColor = Colors.green;
                  } else if (!containsPosition([col, row], viewModel.turquoiseTiles)) {
                    tileColor = Colors.redAccent;
                  } else {
                    tileColor = Colors.teal;
                  }
                  // Calculer l'angle en fonction de la direction
                  double angle = viewModel.currentDirection * (pi / 2);
                  tileContent = Transform.rotate(
                    angle: angle,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: constraints.maxWidth / gridSize * 0.5,
                    ),
                  );
                }

                // Case orange
                for (var pos in viewModel.orangeTiles) {
                  if (samePosition(pos, [col, row])) {
                    tileColor = Colors.orange;
                  }
                }

                // Case violette
                for (var pos in viewModel.violetTiles) {
                  // Verifier qu'elle n'est pas collecté
                  if (samePosition(pos, [col, row]) &&
                      !viewModel.collectedVioletCase2.contains(pos)) {
                    tileColor = Color.fromARGB(255, 121, 3, 130);
                  }
                }

                // Si le diamant est
                if (samePosition([col, row], viewModel.diamant)) {
                  // Sur une étoile
                  for (var star in viewModel.stars) {
                    if (samePosition(viewModel.diamant, star) &&
                        !viewModel.collectedStars2.contains(star)) {
                      // on collecte l'étoile
                      viewModel.collectedStars2.add(star);
                    }
                  }

                  // Sur une case viollete
                  for (var vtile in viewModel.violetTiles) {
                    if (samePosition(viewModel.diamant, vtile) &&
                        !viewModel.collectedVioletCase2.contains(vtile)) {
                      // Si c'est la case de départ (première dans violetTiles)
                      if (samePosition(vtile, viewModel.paternModel.diamant)) {
                        // On collecte uniquement si le diamant a déjà quitté sa position initiale
                        // et qu'il y revient
                        if (viewModel.firstPassage) {
                          viewModel.firstPassage = true;
                          viewModel.collectedVioletCase2.add(vtile);
                        }
                      } else {
                        // Pour les autres cases violettes, on les collecte normalement
                        viewModel.firstPassage = true;
                        viewModel.collectedVioletCase2.add(vtile);
                      }
                    }
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: tileColor,
                    border:
                        Border.all(color: const Color(0xFF444444), width: 0.5),
                  ),
                  child: Center(child: tileContent),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}