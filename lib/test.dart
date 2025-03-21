import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
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
  final Patern patern;
  const GameScreen({super.key, required this.patern});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Taille de la grille
  final int gridSize = 16;
  List<dynamic> actions = [];

  // Chemin
  late List<List<int>> turquoiseTiles;
  late List<List<int>> orangeTiles;

  // Position de depart et position de la cible
  late List<int> diamant;
  late List<List<int>> stars;

  // Ensemble pour suivre les étoiles collectées
  Set<List<int>> collectedStars = {};
  // int targetsReached = 0;
  late int level;

  late List<PathStep> diamondPath;
  late Patern patern;

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
  late int _timeRemaining;
  String _timeDisplay = "1:00:00";
  bool _gameOver = false;

  // Conffiti celebration
  late ConfettiController _controllerCenterRight;
  late ConfettiController _controllerCenterLeft;

  @override
  void initState() {
    super.initState();

    // Initialiser le timer
    startTimer();

    patern = widget.patern;
    _timeRemaining = widget.patern.timeRemaining;
    turquoiseTiles = patern.tile;
    orangeTiles = patern.orangeTile ?? [];
    diamant = patern.diamant;
    stars = patern.star;
    _currentDirection = patern.direction;
    level = patern.niveau;
    diamondPath = [PathStep(diamant, _currentDirection)];

    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 5));
    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 5));
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

      if ((collectedStars.length == stars.length) && !_isAnimating) {
        timer.cancel();
        _controllerCenterLeft.play();
        _controllerCenterRight.play();
        _showWinDialog();
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
                  _timeRemaining = patern.timeRemaining;
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

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Temps écoulé!', style: TextStyle(color: Colors.red)),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E32).withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistiques de jeu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        //
                      },
                      icon: Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Levels completed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Niveaux complétés:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '12/45',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        color: const Color(0xFF333333),
                      ),
                      Container(
                        height: 6,
                        width:
                            MediaQuery.of(context).size.width * 0.9 * (12 / 45),
                        color: const Color(0xFF00CCAA),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),

                // Time played
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Temps de jeu total:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '3h 45m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Perfect sequences
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Séquences parfaites:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '8',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Best time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Meilleur temps (niveau 2):',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      '0:58:54',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00CCAA),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          patern = widget.patern;
                          collectedStars.clear();
                          print(widget.patern);
                          // stars = patern.star;
                          _timeRemaining = patern.timeRemaining;
                          _updateTimeDisplay();
                          _gameOver = false;
                          diamant = patern.diamant;
                          _currentDirection = patern.direction;
                          diamondPath = [PathStep(diamant, _currentDirection)];
                          actions = [];
                        });
                        startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF444444),
                        foregroundColor: Colors.white,
                        minimumSize: Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40 / 2),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Recommencer',
                        style: TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00CCAA),
                        foregroundColor: const Color(0xFF1A1A2E),
                        minimumSize: Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40 / 2),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Suivant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void addPointToPath() {
    actions.forEach((action) {
      final lastStep = diamondPath.last;
      final lastPosition = lastStep.position;
      var currentDirection = lastStep.direction;

      if (!containsPosition(lastPosition)) return;

      if (collectedStars.length != stars.length) {
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
            for (var star in stars) {
              if (samePosition(newPosition, star) &&
                  !collectedStars.contains(star)) {
                collectedStars.add(star);
              }
            }
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
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Convertir les étapes de mouvement en points
    _points = diamondPath
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

            // stars.removeWhere((star) => samePosition(diamant, star));
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
    setState(() {
      _isAnimating = true;
      _currentStepIndex = 0;
    });

    _setupAnimations();

    // Demarer les animations
    _positionController.forward(from: 0.0);
    _rotationController.forward(from: 0.0);
  }

  bool containsPosition(List<int> position, [List<List<int>>? tiles]) {
    for (var tile in tiles ?? turquoiseTiles) {
      if (samePosition(position, tile)) {
        return true;
      }
    }
    return false;
  }

  bool samePosition(List<int> pos1, List<int> pos2) {
    return (pos1[0] == pos2[0]) && (pos1[1] == pos2[1]);
  }

  @override
  void dispose() {
    _timer.cancel();
    // _positionController.dispose();
    // _rotationController.dispose();
    _controllerCenterLeft.dispose();
    _controllerCenterRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final smallScreen = screenSize.shortestSide < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
          ),
        ),
        child: SafeArea(
          child: isPortrait
              ? _buildPortraitLayout(context, smallScreen)
              : _buildLandscapeLayout(context, smallScreen),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, bool smallScreen) {
    return Column(
      children: [
        _buildTopBar(context),
        _buildTimerAndLevel(context),
        _buildControlButtons(context, smallScreen),
        Expanded(
          flex: 5,
          child: _buildGameGrid(context),
        ),
        _buildPathIndicator(context, smallScreen),
        _buildConfetti(),
        Expanded(
          flex: 1,
          child: _buildActionButtons(context, smallScreen),
        ),
        _buildCommandsIndicator(context, smallScreen),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, bool smallScreen) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildTopBar(context),
              _buildTimerAndLevel(context),
              _buildControlButtons(context, smallScreen),
              Expanded(
                child: _buildActionButtons(context, smallScreen),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: _buildGameGrid(context),
              ),
              _buildPathIndicator(context, smallScreen),
              _buildConfetti(),
              _buildCommandsIndicator(context, smallScreen),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
              ),
              child: Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                value: _timeRemaining / widget.patern.timeRemaining,
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerAndLevel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeDisplay,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _timeRemaining < 300 ? Colors.red : Colors.white70,
                ),
              ),
              Text(
                "Niveau $level",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
          // Optionally add something on the right side
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, bool smallScreen) {
    final buttonSize = smallScreen ? 32.0 : 40.0;
    final iconSize = smallScreen ? 16.0 : 20.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ControlButton(
          _isAnimating ? Icons.pause : Icons.play_arrow,
          Colors.white,
          width: buttonSize,
          iconSize: iconSize,
          onPressed: () {
            if (!_isAnimating) {
              setState(() {
                diamondPath = [PathStep(diamant, _currentDirection)];
              });
              addPointToPath();
              if (actions.isNotEmpty) {
                _startAnimation();
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
            if (!_isAnimating) {
              setState(() {
                diamondPath = [PathStep(diamant, _currentDirection)];
                actions = [];
              });
            }
          },
        ),
        ControlButton(
          Icons.close,
          Colors.white,
          width: buttonSize,
          iconSize: iconSize,
        ),
        ControlButton(
          Icons.layers,
          Colors.white,
          width: buttonSize,
          iconSize: iconSize,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildGameGrid(BuildContext context) {
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

                for (var pos in turquoiseTiles) {
                  if (samePosition(pos, [col, row])) {
                    tileColor = Colors.teal;
                  }
                }

                for (var star in stars) {
                  if (samePosition(star, [col, row])) {
                    tileColor = Colors.teal;
                    tileContent = Icon(
                      Icons.star,
                      color: Colors.black,
                      size: constraints.maxWidth / gridSize * 0.5,
                    );
                  }
                }

                if (col == diamant[0] && row == diamant[1]) {
                  // Depart
                  if (containsPosition([col, row], stars)) {
                    tileColor = Colors.green;
                  } else if (!containsPosition([col, row])) {
                    tileColor = Colors.redAccent;
                  } else {
                    tileColor = Colors.teal;
                  }
                  // Calculer l'angle en fonction de la direction
                  double angle = _currentDirection * (pi / 2);
                  tileContent = Transform.rotate(
                    angle: angle,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: constraints.maxWidth / gridSize * 0.5,
                    ),
                  );
                }

                for (var pos in orangeTiles) {
                  if (pos[0] == col && pos[1] == row) {
                    tileColor = Colors.orange;
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

  Widget _buildPathIndicator(BuildContext context, bool smallScreen) {
    final buttonSize = smallScreen ? 16.0 : 20.0;
    final iconSize = smallScreen ? 12.0 : 16.0;

    return SizedBox(
      height: smallScreen ? 80 : 100,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Affichage du point de départ comme un cercle avec une flèche
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
              for (var i = 1; i < diamondPath.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ControlButton(
                    diamondPath[i].isRotation
                        ? (diamondPath[i].direction -
                                        diamondPath[i - 1].direction ==
                                    1 ||
                                diamondPath[i].direction -
                                        diamondPath[i - 1].direction ==
                                    -3)
                            ? Icons.arrow_forward_rounded // Rotation droite
                            : Icons.arrow_back_rounded // Rotation gauche
                        : Icons.arrow_upward,
                    Colors.white,
                    width: buttonSize,
                    iconSize: iconSize,
                    decoColor: containsPosition(diamondPath[i].position)
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

              // Affichage du point d'arrivée comme un cercle avec une étoile
              if (collectedStars.length == stars.length)
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

  Widget _buildConfetti() {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConfettiWidget(
            confettiController: _controllerCenterLeft,
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
            confettiController: _controllerCenterRight,
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
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool smallScreen) {
    final buttonSize = smallScreen ? 36.0 : 45.0;
    final iconSize = smallScreen ? 20.0 : 30.0;

    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var button in patern.buttons)
                InkWell(
                  onTap: () => setState(() {
                    if (actions.length < patern.steps) actions.add(button);
                  }),
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      getIconData(button),
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCommandsIndicator(BuildContext context, bool smallScreen) {
    final buttonSize = smallScreen ? 36.0 : 45.0;
    final iconSize = smallScreen ? 20.0 : 24.0;

    return Container(
      height: buttonSize + 16,
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Icon(Icons.circle_outlined,
                    color: Colors.white, size: iconSize),
              ),
            ),
            for (var action in actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Icon(getIconData(action),
                      color: Colors.white, size: iconSize),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? decoColor;
  final double? width;
  final double? iconSize;
  final VoidCallback? onPressed;

  ControlButton(
    this.icon, 
    this.color, {
    this.onPressed, 
    this.width, 
    this.decoColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width ?? 40,
        height: width ?? 40,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: decoColor ?? const Color(0xFF444444),
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize ?? (width != null ? 16 * width! / 40 : 14),
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



// _widgetTopBar(context), // ~ 40
//         _widgetTimerAndLevel(context), // ~ 50
//         // _widgetControlButtons(context, smallScreen),
//         _widgetGameGrid(context, smallScreen),
//         // Expanded(
//         //   flex: 6,
//         //   child: Container(
//         //     color: Colors.amber,
//         //     child: _widgetGameGrid(context)),
//         // ),
//         _widgetPathIndicator(context, smallScreen), // smallScreen ? 40 : 50
//         _widgetConfetti(), // ~ 0
//         // Expanded(
//         //   flex: 1,
//         //   child: _widgetActionButtons(context, smallScreen), // ~ 40
//         // ),
//         _widgetActionButtons(context, smallScreen),
//         _widgetCommandsIndicator(context, smallScreen), // smallScreen ? 52 : 61