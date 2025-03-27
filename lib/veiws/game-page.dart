// import 'dart:async';
// import 'dart:math';
// import 'package:confetti/confetti.dart';
// import 'package:flutter/material.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:puzzle/MVVM/game-model.dart';
// import 'package:puzzle/MVVM/player-stats-service.dart';
// import 'package:puzzle/actions.dart';
// // import 'package:puzzle/actions.dart';
// import 'package:puzzle/home.dart';
// import 'package:puzzle/paterns.dart';
// import 'package:puzzle/player-model.dart';
// import 'package:puzzle/widgets/controle-button.dart';

// class GameScreen extends StatefulWidget {
//   final PaternModel patern;
//   const GameScreen({super.key, required this.patern});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   // Taille de la grille
//   final int gridSize = 16;
//   List<List<dynamic>> actions1 = [];
//   List<List<dynamic>> actions2 = [];

//   // Chemin
//   late List<List<int>> turquoiseTiles;
//   late List<List<int>> orangeTiles;
//   late List<List<int>> violetTiles;

//   // Position de depart et position de la cible
//   late List<int> diamant;
//   late List<List<int>> stars;

//   // Ensemble pour suivre les étoiles collectées
//   Set<List<int>> collectedStars = {};
//   Set<List<int>> collectedStars2 = {};
//   Set<List<int>> collectedVioletCase = {};
//   Set<List<int>> collectedVioletCase2 = {};
//   late int level;

//   late List<PathStep> diamondPath;
//   late PaternModel patern;

//   // Variables animation
//   late AnimationController _positionController;
//   late AnimationController _rotationController;
//   late Animation<double> _rotationAnimation;
//   late int _currentDirection;
//   List<Offset> _points = [];
//   List<double> _angles = [];
//   int _currentStepIndex = 0;
//   bool _isAnimating = false;

//   // Variables de temps
//   late Timer _timer;
//   late int _timeRemaining;
//   String _timeDisplay = "1:00:00";
//   bool _gameOver = false;

//   Color? _selectedColor;
//   bool firstPassage = false;
//   bool firstPassage2 = false;

//   // Conffiti celebration
//   late ConfettiController _controllerCenterRight;
//   late ConfettiController _controllerCenterLeft;

//   PlayerStats? _playerStats;

//   @override
//   void initState() {
//     super.initState();

//     // Initialiser le timer
//     startTimer();

//     patern = widget.patern;
//     _timeRemaining = widget.patern.timeRemaining;
//     turquoiseTiles = patern.tile;
//     orangeTiles = patern.orangeTile ?? [];
//     violetTiles = patern.violetTile ?? [];
//     diamant = patern.diamant;
//     stars = patern.star;
//     _currentDirection = patern.direction;
//     level = patern.niveau;
//     diamondPath = [PathStep(diamant, _currentDirection)];

//     _controllerCenterLeft =
//         ConfettiController(duration: const Duration(seconds: 5));
//     _controllerCenterRight =
//         ConfettiController(duration: const Duration(seconds: 5));

//     _loadPlayerStats();
//   }

//   Future<void> _loadPlayerStats() async {
//     _playerStats = await PlayerStatsManager.loadStats();
//     _playerStats!.currentLevel = level;
//     await PlayerStatsManager.saveStats(_playerStats!);
//     setState(() {});
//   }

//   void startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if ((collectedStars.length == stars.length) && !_isAnimating) {
//         timer.cancel();
//         _controllerCenterLeft.play();
//         _controllerCenterRight.play();
//         _showWinDialog();
//       }

//       if (_timeRemaining > 0) {
//         setState(() {
//           _timeRemaining--;
//           _updateTimeDisplay();
//         });
//       } else {
//         timer.cancel();
//         setState(() {
//           _gameOver = true;
//         });
//         _showGameOverDialog();
//       }
//     });
//   }

//   String? _updateTimeDisplay({int? timeRemaining}) {
//     int time = timeRemaining ?? _timeRemaining;
//     int hours = time ~/ 3600;
//     int minutes = (time % 3600) ~/ 60;
//     int seconds = time % 60;
//     if (timeRemaining == null) {
//       _timeDisplay =
//           "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
//       return null;
//     } else {
//       String timeDisplay =
//           "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
//       return timeDisplay;
//     }
//   }

//   void _showGameOverDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Temps écoulé!', style: TextStyle(color: Colors.red)),
//           content: Text('Vous avez perdu. Le temps imparti est écoulé.'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Réessayer'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 setState(() {
//                   _timeRemaining = patern.timeRemaining;
//                   _updateTimeDisplay();
//                   _gameOver = false;
//                 });
//                 startTimer();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showWinDialog() async {
//     // Mettre à jour les stats
//     _playerStats!.levelCompleted(
//         level, Duration(seconds: patern.timeRemaining - _timeRemaining));

//     // Sauvegarder les stats mises à jour
//     await PlayerStatsManager.saveStats(_playerStats!);

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           contentPadding: EdgeInsets.all(0),
//           content: Container(
//             padding: EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1E1E32).withOpacity(0.8),
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.5),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Center(
//                   child: Text(
//                     'Félicitations 👑',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Niveaux complétés:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     Text(
//                       '$level/${paterns.length}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF00CCAA),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   height: 10,
//                   child: LinearPercentIndicator(
//                     animation: true,
//                     lineHeight: 7.0,
//                     animationDuration: 1000,
//                     percent:
//                         _playerStats!.completedLevelsCount / paterns.length,
//                     barRadius: const Radius.circular(5),
//                     progressColor: Colors.teal,
//                     backgroundColor: Colors.grey[800],
//                     padding: EdgeInsets.zero,
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Temps de jeu:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     Text(
//                       _updateTimeDisplay(
//                           timeRemaining:
//                               patern.timeRemaining - _timeRemaining)!,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF00CCAA),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         'Meilleur temps (niveau ${_playerStats!.bestTimeLevel}):',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       _playerStats!.formattedbestTime,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF00CCAA),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 15),
//                 TextButton(
//                   onPressed: level == paterns.length
//                       ? null
//                       : () {
//                           Navigator.of(context).pop();
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => GameScreen(
//                                 patern: paterns[level],
//                               ),
//                             ),
//                           );
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF00CCAA),
//                     foregroundColor: const Color(0xFF1A1A2E),
//                     minimumSize: Size(double.infinity, 40),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(40 / 2),
//                     ),
//                     elevation: 5,
//                   ),
//                   child: Text(
//                     'Suivant',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => HomeScreen(
//                               playerStats: _playerStats!,
//                             ),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         fixedSize: Size(120, 40),
//                       ),
//                       child: Text(
//                         'Accueil',
//                         style: TextStyle(
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         setState(() {
//                           patern = widget.patern;
//                           collectedStars.clear();
//                           collectedStars2.clear();
//                           collectedVioletCase.clear();
//                           collectedVioletCase2.clear();
//                           _timeRemaining = patern.timeRemaining;
//                           _updateTimeDisplay();
//                           _gameOver = false;
//                           diamant = patern.diamant;
//                           _currentDirection = patern.direction;
//                           diamondPath = [PathStep(diamant, _currentDirection)];
//                           actions1 = [];
//                           actions2 = [];
//                         });
//                         startTimer();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         fixedSize: Size(120, 40),
//                       ),
//                       child: Text(
//                         'Rejouer',
//                         style: TextStyle(
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void addPointToPath(bool first) {
//     (first ? actions1 : actions2).forEach((action) {
//       final lastStep = diamondPath.last;
//       final lastPosition = lastStep.position;
//       if (!containsPosition(lastPosition)) return;

//       var currentDirection = lastStep.direction;
//       Color lastPositionColor = containsPosition(lastPosition, orangeTiles)
//           ? Colors.orange
//           : (containsPosition(lastPosition, violetTiles) &&
//                   !containsPosition(lastPosition, collectedVioletCase.toList()))
//               ? Color(0xFF790382)
//               : Colors.teal;

//       bool move = (action[1] == Colors.grey || action[1] == lastPositionColor);

//       if (containsPosition(lastPosition, violetTiles) &&
//           !containsPosition(lastPosition, collectedVioletCase.toList())) {
//         if (samePosition(lastPosition, patern.diamant)) {
//           // On collecte uniquement si le diamant a déjà quitté sa position initiale
//           // et qu'il y revient
//           if (firstPassage2) {
//             collectedVioletCase.add(lastPosition);
//             firstPassage2 = true;
//           }
//         } else {
//           // Pour les autres cases violettes, on les collecte normalement
//           firstPassage2 = true;
//           collectedVioletCase.add(lastPosition);
//         }
//       }

//       if (collectedStars.length != stars.length) {
//         if (action[0] == Move.moveFoward && move) {
//           List<int> newPosition;
//           switch (currentDirection) {
//             case 0: // Up
//               newPosition = [lastPosition[0], lastPosition[1] - 1];
//               break;
//             case 1: // Right
//               newPosition = [lastPosition[0] + 1, lastPosition[1]];
//               break;
//             case 2: // Down
//               newPosition = [lastPosition[0], lastPosition[1] + 1];
//               break;
//             case 3: // Left
//               newPosition = [lastPosition[0] - 1, lastPosition[1]];
//               break;
//             default:
//               newPosition = lastPosition;
//           }

//           setState(() {
//             diamondPath.add(PathStep(newPosition, currentDirection));
//             for (var star in stars) {
//               if (samePosition(newPosition, star) &&
//                   !collectedStars.contains(star)) {
//                 collectedStars.add(star);
//               }
//             }
//           });
//           if (!containsPosition(newPosition)) return;
//         } else if (action[0] == Move.rotatLeft && move) {
//           final newDirection = (currentDirection + 3) % 4;
//           setState(() {
//             diamondPath.add(PathStep(List.from(lastPosition), newDirection,
//                 isRotation: true));
//           });
//         } else if (action[0] == Move.rotatRight && move) {
//           final newDirection = (currentDirection + 1) % 4;
//           setState(() {
//             diamondPath.add(PathStep(List.from(lastPosition), newDirection,
//                 isRotation: true));
//           });
//         } else if (action[0] == Move.repetStage0 && move) {
//           if (diamondPath.length > 100) return;
//           addPointToPath(true);
//           return;
//         } else if (action[0] == Move.repetStage1 && move) {
//           if (diamondPath.length > 100) return;
//           addPointToPath(false);
//           return;
//         }
//       }
//     });
//   }

//   void _setupAnimations() {
//     // Convertir les étapes de mouvement en points
//     _points = diamondPath
//         .map((step) =>
//             Offset(step.position[0].toDouble(), step.position[1].toDouble()))
//         .toList();

//     // Créer une liste d'angles
//     _angles = diamondPath.map((step) => step.direction * (pi / 2)).toList();

//     // Initialiser les controllers
//     int totalSteps = _points.length;
//     Duration totalDuration = Duration(milliseconds: totalSteps * 400);

//     // Initialiser les controllers avec la durée calculée
//     _positionController = AnimationController(
//       duration: totalDuration,
//       vsync: this,
//     );

//     _rotationController = AnimationController(
//       duration: totalDuration, // Même durée que le contrôleur de position
//       vsync: this,
//     );

//     // Configurer les animations de position
//     List<Animation<Offset>> positionAnimations = [];
//     for (int i = 0; i < _points.length - 1; i++) {
//       final begin = _points[i];
//       final end = _points[i + 1];

//       final positionAnimation = Tween<Offset>(
//         begin: begin,
//         end: end,
//       ).animate(
//         CurvedAnimation(
//           parent: _positionController,
//           curve: Interval(
//             i / (_points.length - 1),
//             (i + 1) / (_points.length - 1),
//             curve: Curves.linear,
//           ),
//         ),
//       );

//       positionAnimations.add(positionAnimation);
//     }

//     // Ecouter les animations
//     _positionController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {
//           _isAnimating = false;
//           _currentStepIndex = 0;
//           diamant = List.from(diamondPath[0].position);
//           _currentDirection = diamondPath[0].direction;
//           firstPassage = false;
//           firstPassage2 = false;
//         });
//         _positionController.reset();
//         _rotationController.reset();
//       }
//     });

//     // Update l'état en fonction de l'étape d'animation
//     _positionController.addListener(() {
//       setState(() {
//         if (_isAnimating) {
//           // Trouver le segment actuel
//           double animValue = _positionController.value;
//           int segmentIndex = (animValue * (positionAnimations.length)).floor();
//           segmentIndex = segmentIndex.clamp(0, positionAnimations.length - 1);

//           // Update la position du diamant en fonction du segment actuel
//           if (segmentIndex < positionAnimations.length) {
//             final animation = positionAnimations[segmentIndex];
//             diamant = [animation.value.dx.round(), animation.value.dy.round()];
//           }
//         }
//       });
//     });

//     // Configurer les animations de rotation
//     _rotationAnimation = Tween<double>(
//       begin: _angles.first,
//       end: _angles.last,
//     ).animate(_rotationController);

//     _rotationController.addListener(() {
//       setState(() {
//         if (_isAnimating) {
//           // Trouver l'étape de rotation actuelle
//           double fraction = _rotationController.value;
//           int stepIndex = (fraction * (_angles.length - 1)).floor();
//           stepIndex = stepIndex.clamp(0, _angles.length - 2);

//           // Calculer l'angle de rotation
//           double startAngle = _angles[stepIndex];
//           double endAngle = _angles[stepIndex + 1];
//           double localFraction = (fraction * (_angles.length - 1)) - stepIndex;

//           double currentAngle =
//               startAngle + (endAngle - startAngle) * localFraction;
//           _currentDirection = ((currentAngle / (pi / 2)) % 4).round();
//         }
//       });
//     });
//   }

//   void _startAnimation() {
//     setState(() {
//       _isAnimating = true;
//       _currentStepIndex = 0;
//     });

//     _setupAnimations();

//     // Demarer les animations
//     _positionController.forward(from: 0.0);
//     _rotationController.forward(from: 0.0);
//   }

//   bool containsPosition(List<int> position, [List<List<int>>? tiles]) {
//     for (var tile in tiles ?? turquoiseTiles) {
//       if (samePosition(position, tile)) {
//         return true;
//       }
//     }
//     return false;
//   }

//   bool samePosition(List<int> pos1, List<int> pos2) {
//     return (pos1[0] == pos2[0]) && (pos1[1] == pos2[1]);
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     // _positionController.dispose();
//     // _rotationController.dispose();
//     _controllerCenterLeft.dispose();
//     _controllerCenterRight.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isPortrait = screenSize.height > screenSize.width;
//     final smallScreen = screenSize.shortestSide < 600;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
//           ),
//         ),
//         child: SafeArea(
//           child: isPortrait
//               ? _widgetPortraitLayout(context, smallScreen)
//               : _widgetLandscapeLayout(context, smallScreen),
//         ),
//       ),
//     );
//   }

//   Widget _widgetPortraitLayout(BuildContext context, bool smallScreen) {
//     final screenSize = MediaQuery.of(context).size;
//     bool inRow = (screenSize.width - screenSize.height * 0.7) > 0;
//     // print(screenSize.width);
//     // print(screenSize.height);
//     return Column(
//       children: [
//         _widgetTopBar(context),
//         _widgetTimerAndLevel(context),
//         if (!inRow) ...[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: _widgetControlButtons(context, smallScreen),
//           ),
//           SizedBox(
//             height: screenSize.height - screenSize.width > 400
//                 ? screenSize.width
//                 : screenSize.height - 400,
//             child: _widgetGameGrid(context),
//           )
//           // Expanded(
//           //   flex: 7,
//           //   child: _widgetGameGrid(context),
//           // ),
//         ],
//         if (inRow) ...[
//           Expanded(
//             flex: 7,
//             child: Row(
//               children: [
//                 _widgetGameGrid(context),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: _widgetControlButtons(context, smallScreen),
//                 ),
//               ],
//             ),
//           ),
//         ],
//         _widgetPathIndicator(context, smallScreen),
//         _widgetConfetti(),
//         Expanded(
//           flex: 1,
//           child: _widgetActionButtons(context, smallScreen),
//         ),
//         _widgetCommandsIndicator(context, smallScreen),
//         const SizedBox(height: 15),
//       ],
//     );
//   }

//   Widget _widgetLandscapeLayout(BuildContext context, bool smallScreen) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Column(
//             children: [
//               _widgetTopBar(context),
//               _widgetTimerAndLevel(context),
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: _widgetControlButtons(context, smallScreen),
//                     ),
//                     _widgetPathIndicator(context, smallScreen),
//                     _widgetActionButtons(context, smallScreen),
//                     _widgetCommandsIndicator(context, smallScreen),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 4,
//           child: Column(
//             children: [
//               Expanded(
//                 flex: 6,
//                 child: _widgetGameGrid(context),
//               ),
//               _widgetConfetti(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _widgetTopBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomeScreen(
//                     playerStats: _playerStats!,
//                   ),
//                 ),
//               );
//             },
//             icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
//           ),
//           Expanded(
//             child: SliderTheme(
//               data: SliderTheme.of(context).copyWith(
//                 trackHeight: 2.0,
//                 thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
//               ),
//               child: Slider(
//                 activeColor: Colors.white,
//                 inactiveColor: Colors.grey,
//                 value: _timeRemaining / widget.patern.timeRemaining,
//                 onChanged: (value) {},
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _widgetTimerAndLevel(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _timeDisplay,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: _timeRemaining < 300 ? Colors.red : Colors.white70,
//                 ),
//               ),
//               Text(
//                 "Niveau $level",
//                 style: TextStyle(fontSize: 18, color: Colors.white70),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _widgetControlButtons(BuildContext context, bool smallScreen) {
//     final buttonSize = smallScreen ? 32.0 : 40.0;
//     final iconSize = smallScreen ? 16.0 : 20.0;

//     return [
//       ControlButton(
//         _isAnimating ? Icons.pause : Icons.play_arrow,
//         Colors.white,
//         width: buttonSize,
//         iconSize: iconSize,
//         onPressed: () {
//           if (!_isAnimating) {
//             setState(() {
//               diamondPath = [PathStep(diamant, _currentDirection)];
//               collectedStars.clear();
//               collectedStars2.clear();
//               collectedVioletCase.clear();
//               collectedVioletCase2.clear();
//             });
//             addPointToPath(true);
//             if (actions1.isNotEmpty) {
//               _startAnimation();
//             }
//           }
//         },
//       ),
//       ControlButton(
//         Icons.arrow_forward,
//         Colors.white,
//         width: buttonSize,
//         iconSize: iconSize,
//       ),
//       ControlButton(
//         Icons.refresh,
//         Colors.white,
//         width: buttonSize,
//         iconSize: iconSize,
//         onPressed: () {
//           if (!_isAnimating) {
//             setState(() {
//               diamondPath = [PathStep(diamant, _currentDirection)];
//               _selectedColor = null;
//               actions1 = [];
//               actions2 = [];
//               collectedStars.clear();
//               collectedStars2.clear();
//               collectedVioletCase.clear();
//               collectedVioletCase2.clear();
//             });
//           }
//         },
//       ),
//       ControlButton(
//         Icons.close,
//         Colors.white,
//         width: buttonSize,
//         iconSize: iconSize,
//         onPressed: () {
//           if (actions2.isNotEmpty) {
//             setState(() {
//               _selectedColor = null;
//               actions2.removeLast();
//             });
//           } else if (actions1.isNotEmpty) {
//             setState(() {
//               _selectedColor = null;
//               actions1.removeLast();
//             });
//           }
//         },
//       ),
//       ControlButton(
//         Icons.layers,
//         Colors.white,
//         width: buttonSize,
//         iconSize: iconSize,
//         onPressed: () {},
//       ),
//     ];
//   }

//   Widget _widgetGameGrid(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: AspectRatio(
//           aspectRatio: 1.0,
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade800, width: 1),
//             ),
//             child: GridView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: gridSize,
//                 childAspectRatio: 1.0,
//               ),
//               itemCount: gridSize * gridSize,
//               itemBuilder: (context, index) {
//                 final row = index ~/ gridSize;
//                 final col = index % gridSize;

//                 // Type de cellule
//                 Color tileColor = Colors.transparent;
//                 Widget tileContent = SizedBox();

//                 for (var pos in turquoiseTiles) {
//                   if (samePosition(pos, [col, row])) {
//                     tileColor = Colors.teal;
//                   }
//                 }

//                 // Placer les etoiles
//                 for (var star in stars) {
//                   if (samePosition(star, [col, row]) &&
//                       !collectedStars2.contains(star)) {
//                     // tileColor = Colors.teal;
//                     tileContent = Icon(
//                       Icons.star,
//                       color: Colors.black,
//                       size: constraints.maxWidth / gridSize * 0.5,
//                     );
//                   }
//                 }

//                 // Diamant
//                 if (samePosition(diamant, [col, row])) {
//                   // Vert s'il collecte une etoile, turquoise s'il est bien positionné et rouge sinon
//                   if (containsPosition([col, row], stars)) {
//                     tileColor = Colors.green;
//                   } else if (!containsPosition([col, row])) {
//                     tileColor = Colors.redAccent;
//                   } else {
//                     tileColor = Colors.teal;
//                   }
//                   // Calculer l'angle en fonction de la direction
//                   double angle = _currentDirection * (pi / 2);
//                   tileContent = Transform.rotate(
//                     angle: angle,
//                     child: Icon(
//                       Icons.navigation,
//                       color: Colors.white,
//                       size: constraints.maxWidth / gridSize * 0.5,
//                     ),
//                   );
//                 }

//                 // Case orange
//                 for (var pos in orangeTiles) {
//                   if (samePosition(pos, [col, row])) {
//                     tileColor = Colors.orange;
//                   }
//                 }

//                 // Case violette
//                 for (var pos in violetTiles) {
//                   // Verifier qu'elle n'est pas collecté
//                   if (samePosition(pos, [col, row]) &&
//                       !collectedVioletCase2.contains(pos)) {
//                     tileColor = Color.fromARGB(255, 121, 3, 130);
//                   }
//                 }

//                 // Si le diamant est
//                 if (samePosition([col, row], diamant)) {
//                   // Sur une étoile
//                   for (var star in stars) {
//                     if (samePosition(diamant, star) &&
//                         !collectedStars2.contains(star)) {
//                       // on collecte l'étoile
//                       collectedStars2.add(star);
//                     }
//                   }

//                   // Sur une case viollete
//                   for (var vtile in violetTiles) {
//                     if (samePosition(diamant, vtile) &&
//                         !collectedVioletCase2.contains(vtile)) {
//                       // Si c'est la case de départ (première dans violetTiles)
//                       if (samePosition(vtile, patern.diamant)) {
//                         // On collecte uniquement si le diamant a déjà quitté sa position initiale
//                         // et qu'il y revient
//                         if (firstPassage) {
//                           firstPassage = true;
//                           collectedVioletCase2.add(vtile);
//                         }
//                       } else {
//                         // Pour les autres cases violettes, on les collecte normalement
//                         firstPassage = true;
//                         collectedVioletCase2.add(vtile);
//                       }
//                     }
//                   }
//                 }

//                 return Container(
//                   decoration: BoxDecoration(
//                     color: tileColor,
//                     border:
//                         Border.all(color: const Color(0xFF444444), width: 0.5),
//                   ),
//                   child: Center(child: tileContent),
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Widget _widgetPathIndicator(BuildContext context, bool smallScreen) {
//     final buttonSize = smallScreen ? 16.0 : 20.0;
//     final iconSize = smallScreen ? 12.0 : 16.0;

//     return SizedBox(
//       // height: smallScreen ? 80 : 100,
//       height: smallScreen ? 40 : 50,
//       child: LayoutBuilder(builder: (context, constraints) {
//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Affichage du point de départ
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                 child: ControlButton(
//                   Icons.navigation,
//                   Colors.white,
//                   width: buttonSize,
//                   iconSize: iconSize,
//                   decoColor: Colors.green,
//                 ),
//               ),

//               // Affichage de chaque étape du chemin
//               for (var i = 1; i < diamondPath.length; i++)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                   child: ControlButton(
//                     diamondPath[i].isRotation
//                         ? (diamondPath[i].direction -
//                                         diamondPath[i - 1].direction ==
//                                     1 ||
//                                 diamondPath[i].direction -
//                                         diamondPath[i - 1].direction ==
//                                     -3)
//                             ? Icons.arrow_forward_rounded // Rotation droite
//                             : Icons.arrow_back_rounded // Rotation gauche
//                         : Icons.arrow_upward,
//                     Colors.white,
//                     width: buttonSize,
//                     iconSize: iconSize,
//                     decoColor:
//                         containsPosition(diamondPath[i].position, orangeTiles)
//                             ? Colors.orange
//                             : (containsPosition(
//                                     diamondPath[i].position, violetTiles))
//                                 ? Color(0xFF790382)
//                                 : containsPosition(diamondPath[i].position)
//                                     ? Colors.green
//                                     : Colors.red,
//                   ),
//                 ),

//               // Affichage du point d'arrivé
//               if (collectedStars.length == stars.length)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: ControlButton(
//                     Icons.star,
//                     Colors.white,
//                     width: buttonSize,
//                     iconSize: iconSize,
//                     decoColor: Colors.green,
//                   ),
//                 ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _widgetConfetti() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ConfettiWidget(
//           confettiController: _controllerCenterLeft,
//           blastDirection: -pi / 3,
//           maxBlastForce: 60,
//           minBlastForce: 40,
//           particleDrag: 0.05,
//           emissionFrequency: 0.05,
//           numberOfParticles: 20,
//           gravity: 0.05,
//           shouldLoop: false,
//           colors: const [Colors.green, Colors.blue, Colors.pink],
//           strokeWidth: 1,
//           strokeColor: Colors.white,
//         ),
//         ConfettiWidget(
//           confettiController: _controllerCenterRight,
//           blastDirection: -2 * pi / 3,
//           particleDrag: 0.05,
//           emissionFrequency: 0.05,
//           numberOfParticles: 20,
//           maxBlastForce: 60,
//           minBlastForce: 40,
//           gravity: 0.05,
//           shouldLoop: false,
//           colors: const [Colors.green, Colors.blue, Colors.pink],
//           strokeWidth: 1,
//           strokeColor: Colors.white,
//         ),
//       ],
//     );
//   }

//   Widget _widgetActionButtons(BuildContext context, bool smallScreen) {
//     final buttonSize = smallScreen ? 36.0 : 45.0;
//     final iconSize = smallScreen ? 20.0 : 30.0;

//     return LayoutBuilder(builder: (context, constraints) {
//       return Center(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               for (var button in patern.buttons)
//                 Builder(builder: (context) {
//                   bool colorSelected =
//                       button is Color && button == _selectedColor;
//                   return InkWell(
//                     onTap: () => setState(() {
//                       if (actions1.length < patern.steps0) {
//                         if (button is Color) {
//                           _selectedColor = button;
//                           colorSelected = true;
//                         } else {
//                           if (button == Move.repetStage0 ||
//                               button == Move.repetStage1) {
//                             actions1
//                                 .add([button, _selectedColor ?? Colors.grey]);
//                             _selectedColor = null;
//                             return;
//                           }

//                           actions1.add([button, _selectedColor ?? Colors.grey]);
//                           _selectedColor = null;
//                           // if (_selectedColor != null) {
//                           // } else {
//                           //   actions1.add([button, Colors.grey]);
//                           // }
//                         }
//                       } else if (patern.steps1 != null) {
//                         if (actions2.length < patern.steps1!) {
//                           if (button is Color) {
//                             _selectedColor = button;
//                             colorSelected = true;
//                           } else {
//                             if (button == Move.repetStage0 ||
//                                 button == Move.repetStage1) {
//                               actions2
//                                   .add([button, _selectedColor ?? Colors.grey]);
//                               _selectedColor = null;
//                               return;
//                             }

//                             actions2
//                                 .add([button, _selectedColor ?? Colors.grey]);
//                             _selectedColor = null;
//                             // if (_selectedColor != null) {
//                             // } else {
//                             //   actions2.add([button, Colors.grey]);
//                             // }
//                           }
//                         }
//                       }
//                     }),
//                     child: Container(
//                       width: buttonSize,
//                       height: buttonSize,
//                       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
//                       decoration: BoxDecoration(
//                         color: button is Color ? button : Colors.grey.shade900,
//                         borderRadius: BorderRadius.circular(5),
//                         border: colorSelected
//                             ? Border.all(color: Colors.white)
//                             : null,
//                       ),
//                       child: button is Color
//                           ? null
//                           : Icon(
//                               getIconData(button),
//                               color: Colors.white,
//                               size: iconSize,
//                             ),
//                     ),
//                   );
//                 }),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _widgetCommandsIndicator(BuildContext context, bool smallScreen) {
//     final buttonSize = smallScreen ? 36.0 : 45.0;
//     final iconSize = smallScreen ? 20.0 : 24.0;

//     return Container(
//       height: (buttonSize + 16) * (patern.steps1 != null ? 2 : 1),
//       color: Colors.grey.shade900,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                   child: Container(
//                     width: buttonSize,
//                     height: buttonSize,
//                     margin: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade800,
//                       border: Border.all(color: Colors.black, width: 1),
//                     ),
//                     child: Icon(Icons.exposure_zero_rounded,
//                         color: Colors.white, size: iconSize),
//                   ),
//                 ),
//                 for (var action in actions1)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: Container(
//                       width: buttonSize,
//                       height: buttonSize,
//                       margin: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: action[1] != Colors.grey
//                             ? action[1]
//                             : Colors.grey.shade800,
//                         border: Border.all(color: Colors.black, width: 1),
//                       ),
//                       child: Icon(
//                         getIconData(action[0]),
//                         color: Colors.white,
//                         size: iconSize,
//                       ),
//                     ),
//                   ),
//                 for (var i = 0; i < patern.steps0 - actions1.length; i++)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: Container(
//                       width: buttonSize,
//                       height: buttonSize,
//                       margin: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade800,
//                         border: Border.all(color: Colors.black, width: 1),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             if (patern.steps1 != null)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: Container(
//                       width: buttonSize,
//                       height: buttonSize,
//                       margin: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade800,
//                         border: Border.all(color: Colors.black, width: 1),
//                       ),
//                       child: Icon(Icons.one_x_mobiledata_rounded,
//                           color: Colors.white, size: iconSize),
//                     ),
//                   ),
//                   for (var action in actions2)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                       child: Container(
//                         width: buttonSize,
//                         height: buttonSize,
//                         margin: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: action[1] != Colors.grey
//                               ? action[1]
//                               : Colors.grey.shade800,
//                           border: Border.all(color: Colors.black, width: 1),
//                         ),
//                         child: Icon(
//                           getIconData(action[0]),
//                           color: Colors.white,
//                           size: iconSize,
//                         ),
//                       ),
//                     ),
//                   for (var i = 0; i < patern.steps1! - actions2.length; i++)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                       child: Container(
//                         width: buttonSize,
//                         height: buttonSize,
//                         margin: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade800,
//                           border: Border.all(color: Colors.black, width: 1),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }