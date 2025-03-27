// import 'package:flutter/material.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:provider/provider.dart';
// import 'package:puzzle/MVVM/game-view.dart';
// import 'package:puzzle/MVVM/game-viewmodel.dart';
// import 'package:puzzle/MVVM/navigation-service.dart';
// import 'package:puzzle/home.dart';
// import 'package:puzzle/paterns.dart';

// class WinDialogWidget extends StatelessWidget {
//   const WinDialogWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<GameViewModel>(context);
//     return AlertDialog(
//       contentPadding: EdgeInsets.all(0),
//       content: Container(
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E1E32).withOpacity(0.8),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Center(
//               child: Text(
//                 'Félicitations 👑',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Niveaux complétés:',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 Text(
//                   '${viewModel.level}/${paterns.length}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF00CCAA),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: 10,
//               child: LinearPercentIndicator(
//                 animation: true,
//                 lineHeight: 7.0,
//                 animationDuration: 1000,
//                 percent:
//                     viewModel.playerStats.completedLevelsCount / paterns.length,
//                 barRadius: const Radius.circular(5),
//                 progressColor: Colors.teal,
//                 backgroundColor: Colors.grey[800],
//                 padding: EdgeInsets.zero,
//               ),
//             ),
//             SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Temps de jeu:',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 Text(
//                   _timeDisplay(viewModel.paternModel.timeRemaining -
//                       viewModel.timeRemaining)!,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF00CCAA),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Text(
//                     'Meilleur temps (niveau ${viewModel.playerStats.bestTimeLevel}):',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   viewModel.playerStats.formattedbestTime,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF00CCAA),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 15),
//             TextButton(
//               onPressed: viewModel.level == paterns.length
//                   ? null
//                   : () {
//                       NavigationService.goBack();
//                       NavigationService.navigateReplacementTo(GameScreen(
//                         // paternModel: paterns[viewModel.level],
//                       ));
//                       // Navigator.of(context).pop();
//                       // Navigator.pushReplacement(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) => GameScreen(
//                       //       paternModel: paterns[viewModel.level],
//                       //     ),
//                       //   ),
//                       // );
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00CCAA),
//                 foregroundColor: const Color(0xFF1A1A2E),
//                 minimumSize: Size(double.infinity, 40),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40 / 2),
//                 ),
//                 elevation: 5,
//               ),
//               child: Text(
//                 'Suivant',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     NavigationService.goBack();
//                     NavigationService.navigateReplacementTo(HomeScreen(
//                       // playerStats: viewModel.playerStats,
//                     ));
//                     // Navigator.of(context).pop();
//                     // Navigator.pushReplacement(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => HomeScreen(
//                     //       playerStats: viewModel.playerStats,
//                     //     ),
//                     //   ),
//                     // );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     fixedSize: Size(120, 40),
//                   ),
//                   child: Text(
//                     'Accueil',
//                     style: TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     NavigationService.goBack();
//                     // Navigator.of(context).pop();
//                     viewModel.resetGame();
//                     // setState(() {
//                     //   patern = widget.patern;
//                     //   collectedStars.clear();
//                     //   collectedStars2.clear();
//                     //   collectedVioletCase.clear();
//                     //   collectedVioletCase2.clear();
//                     //   _timeRemaining = patern.timeRemaining;
//                     //   _updateTimeDisplay();
//                     //   _gameOver = false;
//                     //   diamant = patern.diamant;
//                     //   _currentDirection = patern.direction;
//                     //   diamondPath = [PathStep(diamant, _currentDirection)];
//                     //   actions1 = [];
//                     //   actions2 = [];
//                     // });
//                     // startTimer();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     fixedSize: Size(120, 40),
//                   ),
//                   child: Text(
//                     'Rejouer',
//                     style: TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String? _timeDisplay(int timeRemaining) {
//     int time = timeRemaining;
//     int hours = time ~/ 3600;
//     int minutes = (time % 3600) ~/ 60;
//     int seconds = time % 60;
//     String timeDisplay =
//         "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
//     return timeDisplay;
//   }
// }
