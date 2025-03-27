import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/widgets/controle-button.dart';

class PathindIcatorWidget extends StatelessWidget {
  const PathindIcatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final smallScreen = screenSize.shortestSide < 600;
    final buttonSize = smallScreen ? 16.0 : 20.0;
    final iconSize = smallScreen ? 12.0 : 16.0;

    return SizedBox(
      // height: smallScreen ? 80 : 100,
      height: smallScreen ? 40 : 50,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Affichage du point de départ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ControlButton(
                  Icons.navigation,
                  Colors.white,
                  width: buttonSize,
                  iconSize: iconSize,
                  decoColor: Colors.green,
                ),
              ),

              // Affichage de chaque étape du chemin
              for (var i = 1; i < viewModel.diamondPath.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ControlButton(
                    viewModel.diamondPath[i].isRotation
                        ? (viewModel.diamondPath[i].direction -
                                        viewModel.diamondPath[i - 1].direction ==
                                    1 ||
                                viewModel.diamondPath[i].direction -
                                        viewModel.diamondPath[i - 1].direction ==
                                    -3)
                            ? Icons.arrow_forward_rounded // Rotation droite
                            : Icons.arrow_back_rounded // Rotation gauche
                        : Icons.arrow_upward,
                    Colors.white,
                    width: buttonSize,
                    iconSize: iconSize,
                    decoColor:
                        containsPosition(viewModel.diamondPath[i].position, viewModel.orangeTiles)
                            ? Colors.orange
                            : (containsPosition(
                                    viewModel.diamondPath[i].position, viewModel.violetTiles))
                                ? Color(0xFF790382)
                                : containsPosition(viewModel.diamondPath[i].position, viewModel.turquoiseTiles)
                                    ? Colors.green
                                    : Colors.red,
                  ),
                ),

              // Affichage du point d'arrivé
              if (viewModel.collectedStars.length == viewModel.stars.length)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ControlButton(
                    Icons.star,
                    Colors.white,
                    width: buttonSize,
                    iconSize: iconSize,
                    decoColor: Colors.green,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}