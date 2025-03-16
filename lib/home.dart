import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle/actions.dart';
import 'package:puzzle/paterns.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
  late List<int> star;

  late List<List<int>> diamondPath;

  // Animation variables
  late AnimationController _controller;
  late List<Animation<Offset>> _animations;
  List<Offset> _pathPoints = [];
  bool _isAnimating = false;
  int _currentPointIndex = 0;

  // Timer variables
  late Timer _timer;
  int _timeRemaining = 3600; // 1 heure en secondes
  String _timeDisplay = "1:00:00";
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    
    // Initialiser le timer
    startTimer();

    turquoiseTiles = patern1['turquoiseTiles'];
    orangeTiles = patern1['orangeTiles'] ?? [];
    diamant = patern1['diamant'];
    star = patern1['star'];
    diamondPath = [diamant];
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
    _timeDisplay = "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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

  void _setupAnimations() {
    _animations = [];

    // Convertir les positions de grille en points de chemin
    _pathPoints = [];
    for (var pos in diamondPath) {
      _pathPoints.add(Offset(pos[0].toDouble(), pos[1].toDouble()));
    }

    // Initialiser l'animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    for (int i = 0; i < _pathPoints.length - 1; i++) {
      final begin = _pathPoints[i];
      final end = _pathPoints[i + 1];

      final animation = Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i / (_pathPoints.length - 1),
            (i + 1) / (_pathPoints.length - 1),
            curve: Curves.linear,
          ),
        ),
      );

      _animations.add(animation);

      animation.addListener(() {
        setState(() {
          if (_isAnimating && _currentPointIndex == i) {
            // Mettre à jour la position du diamant pendant l'animation
            diamant = [animation.value.dx.round(), animation.value.dy.round()];

            // Passer au segment suivant si ce segment est termine
            if (animation.value == end) {
              _currentPointIndex = i + 1;
            }
          }
        });
      });
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _currentPointIndex = 0;
          // Remettre le diamant à sa position initiale après l'animation
          diamant = List.from(diamondPath[0]);
        });
        _controller.reset();
      }
    });
  }

  void _startAnimation() {
    _setupAnimations();
    setState(() {
      _isAnimating = true;
      _currentPointIndex = 0;
    });
    _controller.forward(from: 0.0);
  }

  void addPointToPath() {
    for (var action in actions) {
      final lastPosition = diamondPath.last;
      if ((lastPosition[0] != star[0]) || (lastPosition[1] != star[1])) {
        if (action == Move.moveFoward) {
          setState(() {
            diamondPath.add([lastPosition[0] + 1, lastPosition[1]]);
          });
        } else if (action == Move.repet) {
          if (diamondPath.length > 10) {
            return;
          }
          addPointToPath();
          return;
        }
      } else {
        return;
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
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
                      color: _timeRemaining < 300 ? Colors.red : Colors.white70
                    )
                  ),
                  Text(
                    "Niveau 1",
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
                      diamondPath = [diamant];
                    });
                    addPointToPath();
                    _startAnimation();
                  }
                },
              ),
              ControlButton(Icons.arrow_forward, Colors.white),
              ControlButton(Icons.refresh, Colors.white),
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
                      tileContent = Transform.rotate(
                        angle: patern1['angle'],
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

          // Buttons de controle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var button in patern1['buttons'])
                InkWell(
                  onTap: () => setState(() {
                    if (actions.length < patern1['number']) actions.add(button);
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
  final VoidCallback? onPressed;

  ControlButton(this.icon, this.color, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
        ),
        child: Icon(icon, color: color),
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
