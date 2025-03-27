import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-model.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/widgets/controle-button.dart';

class Controlbuttons extends StatefulWidget {
  final bool isPortrait;
  const Controlbuttons({super.key, required this.isPortrait});

  @override
  State<Controlbuttons> createState() => _ControlbuttonsState();
}

class _ControlbuttonsState extends State<Controlbuttons>
    with TickerProviderStateMixin {
  // Variables animation
  late AnimationController _positionController;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  List<Offset> _points = [];
  List<double> _angles = [];
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    bool inRow = (screenSize.width - screenSize.height * 0.7) > 0;
    final smallScreen = screenSize.shortestSide < 600;

    if (inRow && widget.isPortrait) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _widgetControlButtons(context, smallScreen, viewModel),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _widgetControlButtons(context, smallScreen, viewModel),
      );
    }
  }

  List<Widget> _widgetControlButtons(
      BuildContext context, bool smallScreen, GameViewModel viewModel) {
    final buttonSize = smallScreen ? 32.0 : 40.0;
    final iconSize = smallScreen ? 16.0 : 20.0;

    return [
      ControlButton(
        viewModel.isAnimating ? Icons.pause : Icons.play_arrow,
        Colors.white,
        width: buttonSize,
        iconSize: iconSize,
        onPressed: () {
          if (!viewModel.isAnimating) {
            setState(() {
              viewModel.diamondPath = [
                PathStep(viewModel.diamant, viewModel.currentDirection)
              ];
              viewModel.collectedStars.clear();
              viewModel.collectedStars2.clear();
              viewModel.collectedVioletCase.clear();
              viewModel.collectedVioletCase2.clear();
            });
            viewModel.addPointToPath(true);
            if (viewModel.actions1.isNotEmpty) {
              _startAnimation(viewModel);
            }
          }
        },
      ),
      ControlButton(
        Icons.arrow_forward,
        Colors.white,
        width: buttonSize,
        iconSize: iconSize,
      ),
      ControlButton(
        Icons.refresh,
        Colors.white,
        width: buttonSize,
        iconSize: iconSize,
        onPressed: () {
          if (!viewModel.isAnimating) {
            setState(() {
              viewModel.diamondPath = [
                PathStep(viewModel.diamant, viewModel.currentDirection)
              ];
              viewModel.setColor(null);
              viewModel.actions1 = [];
              viewModel.actions2 = [];
              viewModel.collectedStars.clear();
              viewModel.collectedStars2.clear();
              viewModel.collectedVioletCase.clear();
              viewModel.collectedVioletCase2.clear();
            });
          }
        },
      ),
      ControlButton(
        Icons.close,
        Colors.white,
        width: buttonSize,
        iconSize: iconSize,
        onPressed: () {
          if (viewModel.actions2.isNotEmpty) {
            setState(() {
              viewModel.setColor(null);
              viewModel.actions2.removeLast();
            });
          } else if (viewModel.actions1.isNotEmpty) {
            setState(() {
              viewModel.setColor(null);
              viewModel.actions1.removeLast();
            });
          }
        },
      ),
      ControlButton(
        Icons.layers,
        Colors.white,
        width: buttonSize,
        iconSize: iconSize,
        onPressed: () {},
      ),
    ];
  }

  void _setupAnimations(GameViewModel viewModel) {
    // Convertir les étapes de mouvement en points
    _points = viewModel.diamondPath
        .map((step) =>
            Offset(step.position[0].toDouble(), step.position[1].toDouble()))
        .toList();

    // Créer une liste d'angles
    _angles =
        viewModel.diamondPath.map((step) => step.direction * (pi / 2)).toList();

    // Initialiser les controllers
    int totalSteps = _points.length;
    Duration totalDuration = Duration(milliseconds: totalSteps * 400);

    // Initialiser les controllers avec la durée calculée
    _positionController = AnimationController(
      duration: totalDuration,
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: totalDuration, // Même durée que le contrôleur de position
      vsync: this,
    );

    // Configurer les animations de position
    List<Animation<Offset>> positionAnimations = [];
    for (int i = 0; i < _points.length - 1; i++) {
      final begin = _points[i];
      final end = _points[i + 1];

      final positionAnimation = Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          parent: _positionController,
          curve: Interval(
            i / (_points.length - 1),
            (i + 1) / (_points.length - 1),
            curve: Curves.linear,
          ),
        ),
      );

      positionAnimations.add(positionAnimation);
    }

    // Ecouter les animations
    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          viewModel.setIsAnimatedValue(false);
          _currentStepIndex = 0;
          viewModel.diamant = List.from(viewModel.diamondPath[0].position);
          viewModel
              .setCurrentDirectionValue(viewModel.diamondPath[0].direction);
          viewModel.firstPassage = false;
          viewModel.firstPassage2 = false;
        });
        _positionController.reset();
        _rotationController.reset();
      }
    });

    // Update l'état en fonction de l'étape d'animation
    _positionController.addListener(() {
      setState(() {
        if (viewModel.isAnimating) {
          // Trouver le segment actuel
          double animValue = _positionController.value;
          int segmentIndex = (animValue * (positionAnimations.length)).floor();
          segmentIndex = positionAnimations.isNotEmpty
              ? segmentIndex.clamp(0, positionAnimations.length - 1)
              : 0;

          // Update la position du diamant en fonction du segment actuel
          if (segmentIndex < positionAnimations.length) {
            final animation = positionAnimations[segmentIndex];
            viewModel.diamant = [
              animation.value.dx.round(),
              animation.value.dy.round()
            ];
          }
        }
      });
    });

    // Configurer les animations de rotation
    _rotationAnimation = Tween<double>(
      begin: _angles.first,
      end: _angles.last,
    ).animate(_rotationController);

    _rotationController.addListener(() {
      setState(() {
        if (viewModel.isAnimating) {
          // Trouver l'étape de rotation actuelle
          double fraction = _rotationController.value;
          int stepIndex = (fraction * (_angles.length - 1)).floor();
          if (_angles.length > 1) {
            stepIndex = stepIndex.clamp(0, _angles.length - 2);

            // Calculer l'angle de rotation
            double startAngle = _angles[stepIndex];
            double endAngle = _angles[stepIndex + 1];
            double localFraction =
                (fraction * (_angles.length - 1)) - stepIndex;

            double currentAngle =
                startAngle + (endAngle - startAngle) * localFraction;
            viewModel.setCurrentDirectionValue(
                ((currentAngle / (pi / 2)) % 4).round());
          }
        }
      });
    });
  }

  void _startAnimation(GameViewModel viewModel) {
    setState(() {
      viewModel.setIsAnimatedValue(true);
      _currentStepIndex = 0;
    });

    _setupAnimations(viewModel);

    // Demarer les animations
    _positionController.forward(from: 0.0);
    _rotationController.forward(from: 0.0);
  }
}
