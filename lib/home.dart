import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle/actions.dart';
import 'package:puzzle/paterns.dart';

class PathStep {
  final List<int> position;
  final int direction;
  final bool isRotation;

  PathStep(this.position, this.direction, {this.isRotation = false});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Taille de la grille
  final int gridSize = 16;
  List<dynamic> actions = [];
  List<List<dynamic>> allActions = [];

  // Chemin
  late List<List<int>> turquoiseTiles;
  late List<List<int>> orangeTiles;

  // Position de depart et position de la cible
  late List<int> diamant;
  late List<int> star;
  late int level;

  late List<PathStep> diamondPath;
  late Map<String, dynamic> patern;

  // Variables animation
  late AnimationController _positionController;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late int _currentDirection;
  List<Offset> _points = [];
  List<double> _angles = [];
  int _currentStepIndex = 0;
  bool _isAnimating = false;

  // Variables de temps
  late Timer _timer;
  int _timeRemaining = 3600;
  String _timeDisplay = "1:00:00";
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();

    // Initialiser le timer
    startTimer();

    patern = patern3;

    turquoiseTiles = patern['turquoiseTiles'];
    orangeTiles = patern['orangeTiles'] ?? [];
    diamant = patern['diamant'];
    star = patern['star'];
    _currentDirection = patern['direction'];
    level = patern['niveau'];
    diamondPath = [PathStep(diamant, _currentDirection)];
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
          _updateTimeDisplay();
        });
      } else {
        timer.cancel();
        setState(() {
          _gameOver = true;
        });
        _showGameOverDialog();
      }
    });
  }

  void _updateTimeDisplay() {
    int hours = _timeRemaining ~/ 3600;
    int minutes = (_timeRemaining % 3600) ~/ 60;
    int seconds = _timeRemaining % 60;
    _timeDisplay =
        "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Temps écoulé!', style: TextStyle(color: Colors.red)),
          content: Text('Vous avez perdu. Le temps imparti est écoulé.'),
          actions: <Widget>[
            TextButton(
              child: Text('Réessayer'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _timeRemaining = 3600;
                  _updateTimeDisplay();
                  _gameOver = false;
                });
                startTimer();
              },
            ),
          ],
        );
      },
    );
  }

  void addPointToPath() {
    // if (actions.isEmpty)  return;
    actions.forEach((action) {
      final lastStep = diamondPath.last;
      final lastPosition = lastStep.position;
      var currentDirection = lastStep.direction;

      if (!containsPosition(lastPosition)) return;

      setState(() {
        if (action != Move.repet) {
          allActions.add([action, const Color(0xFF212121)]);
        }
      });

      if ((lastPosition[0] != star[0]) || (lastPosition[1] != star[1])) {
        if (action == Move.moveFoward) {
          List<int> newPosition;
          switch (currentDirection) {
            case 0: // Up
              newPosition = [lastPosition[0], lastPosition[1] - 1];
              break;
            case 1: // Right
              newPosition = [lastPosition[0] + 1, lastPosition[1]];
              break;
            case 2: // Down
              newPosition = [lastPosition[0], lastPosition[1] + 1];
              break;
            case 3: // Left
              newPosition = [lastPosition[0] - 1, lastPosition[1]];
              break;
            default:
              newPosition = lastPosition;
          }

          setState(() {
            diamondPath.add(PathStep(newPosition, currentDirection));
          });
          if (!containsPosition(newPosition)) return;
        } else if (action == Move.rotatLeft) {
          final newDirection = (currentDirection + 3) % 4;
          setState(() {
            diamondPath.add(PathStep(List.from(lastPosition), newDirection,
                isRotation: true));
          });
        } else if (action == Move.rotatRight) {
          final newDirection = (currentDirection + 1) % 4;
          setState(() {
            diamondPath.add(PathStep(List.from(lastPosition), newDirection,
                isRotation: true));
          });
        } else if (action == Move.repet) {
          addPointToPath();
          return;
        }
      }
    });
  }

  void _setupAnimations() {
    // Initialiser les controllers
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Créer une liste de mouvement uniquement pour l'animation de position
    List<PathStep> movementSteps =
        diamondPath.where((step) => !step.isRotation).toList();

    // Convertir les étapes de mouvement en points
    _points = movementSteps
        .map((step) =>
            Offset(step.position[0].toDouble(), step.position[1].toDouble()))
        .toList();

    // Créer une liste d'angles
    _angles = diamondPath.map((step) => step.direction * (pi / 2)).toList();

    // Configurer les animations de position
    List<Animation<Offset>> positionAnimations = [];
    for (int i = 0; i < _points.length - 1; i++) {
      final begin = _points[i];
      final end = _points[i + 1];

      final animation = Tween<Offset>(
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

      positionAnimations.add(animation);
    }

    // Ecouter les animations
    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _currentStepIndex = 0;
          diamant = List.from(diamondPath[0].position);
          _currentDirection = diamondPath[0].direction;
        });
        _positionController.reset();
        _rotationController.reset();
      }
    });

    // Update l'état en fonction de l'étape d'animation
    _positionController.addListener(() {
      setState(() {
        if (_isAnimating) {
          // Trouver le segment actuel
          double animValue = _positionController.value;
          int segmentIndex = (animValue * (positionAnimations.length)).floor();
          segmentIndex = segmentIndex.clamp(0, positionAnimations.length - 1);

          // Update la position du diamant en fonction du segment actuel
          if (segmentIndex < positionAnimations.length) {
            final animation = positionAnimations[segmentIndex];
            diamant = [animation.value.dx.round(), animation.value.dy.round()];

            if (containsPosition(diamant)) {
              allActions[segmentIndex][1] = Colors.green;
            } else {
              allActions[segmentIndex][1] = Colors.redAccent;
            }
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
        if (_isAnimating) {
          // Trouver l'étape de rotation actuelle
          double fraction = _rotationController.value;
          int stepIndex = (fraction * (_angles.length - 1)).floor();
          stepIndex = stepIndex.clamp(0, _angles.length - 2);

          // Calculer l'angle de rotation
          double startAngle = _angles[stepIndex];
          double endAngle = _angles[stepIndex + 1];
          double localFraction = (fraction * (_angles.length - 1)) - stepIndex;

          double currentAngle =
              startAngle + (endAngle - startAngle) * localFraction;
          _currentDirection = ((currentAngle / (pi / 2)) % 4).round();
        }
      });
    });
  }

  void _startAnimation() {
    _setupAnimations();
    setState(() {
      _isAnimating = true;
      _currentStepIndex = 0;
    });

    // Demarer les animations
    _positionController.forward(from: 0.0);
    _rotationController.forward(from: 0.0);
  }

  bool containsPosition(List<int> position) {
    for (var tile in turquoiseTiles) {
      if (tile[0] == position[0] && tile[1] == position[1]) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _timer.cancel();
    _positionController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
              ),
              child: Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                value: _timeRemaining / 3600,
                onChanged: (value) {},
              ),
            ),
          ),

          // Temps et Niveau
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeDisplay,
                    style: TextStyle(
                      fontSize: 22,
                      color: _timeRemaining < 300 ? Colors.red : Colors.white70,
                    ),
                  ),
                  Text(
                    "Niveau $level",
                    style: TextStyle(fontSize: 24, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ControlButton(
                _isAnimating ? Icons.pause : Icons.play_arrow,
                Colors.white,
                onPressed: () {
                  if (!_isAnimating) {
                    setState(() {
                      diamondPath = [PathStep(diamant, _currentDirection)];
                      allActions = [];
                    });
                    addPointToPath();
                    if (actions.isNotEmpty) {
                      _startAnimation();
                    }
                  }
                },
              ),
              ControlButton(Icons.arrow_forward, Colors.white),
              ControlButton(
                Icons.refresh,
                Colors.white,
                onPressed: () {
                  if (!_isAnimating) {
                    setState(() {
                      diamondPath = [PathStep(diamant, _currentDirection)];
                      actions = [];
                      allActions = [];
                    });
                  }
                },
              ),
              ControlButton(Icons.close, Colors.white),
              ControlButton(Icons.layers, Colors.white),
            ],
          ),

          // Grille de jeu
          Padding(
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

                    for (var pos in turquoiseTiles) {
                      if (pos[0] == col && pos[1] == row) {
                        tileColor = Colors.teal;
                      }
                    }

                    for (var pos in orangeTiles) {
                      if (pos[0] == col && pos[1] == row) {
                        tileColor = Colors.orange;
                      }
                    }

                    if (col == diamant[0] && row == diamant[1]) {
                      // Depart
                      tileColor = Colors.teal;
                      // Calculer l'angle en fonction de la direction
                      double angle = _currentDirection * (pi / 2);
                      tileContent = Transform.rotate(
                        angle: angle,
                        child: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 12,
                        ),
                      );
                    }

                    if (col == star[0] && row == star[1]) {
                      // Cible
                      tileColor = Colors.teal;
                      tileContent =
                          Icon(Icons.star, color: Colors.black, size: 12);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: tileColor,
                        border:
                            Border.all(color: Colors.grey.shade800, width: 0.5),
                      ),
                      child: Center(child: tileContent),
                    );
                  },
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: allActions.isEmpty
                ? [SizedBox(height: 30)]
                : allActions
                    .map((action) => ControlButton(
                          getIconData(action[0]),
                          Colors.white,
                          width: 20,
                          decoColor: action[1],
                        ))
                    .toList(),
          ),

          // Buttons de controle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var button in patern['buttons'])
                InkWell(
                  onTap: () => setState(() {
                    if (actions.length < patern['steps']) actions.add(button);
                  }),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      getIconData(button),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),

          // Indicateur
          Container(
            height: 60,
            color: Colors.grey.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CommandButton(Icons.circle_outlined, Colors.grey.shade800),
                for (var action in actions)
                  CommandButton(getIconData(action), Colors.grey.shade800)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // bool play() {

  // }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? decoColor;
  final double? width;
  final VoidCallback? onPressed;

  ControlButton(this.icon, this.color,
      {this.onPressed, this.width, this.decoColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width ?? 40,
        height: width ?? 40,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: decoColor ?? const Color(0xFF212121),
        ),
        child: Icon(
          icon,
          color: color,
          size: width != null ? 16 * width! / 40 : 14,
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color textColor;

  ColorButton(this.icon, this.color, {this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Icon(icon, color: textColor),
    );
  }
}

class ColorBox extends StatelessWidget {
  final Color color;

  ColorBox(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      color: color,
    );
  }
}

class CommandButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  CommandButton(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
