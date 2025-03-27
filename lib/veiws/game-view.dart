import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-model.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/widgets/action-buttons-widget.dart';
import 'package:puzzle/widgets/commands-indicator-widget.dart';
import 'package:puzzle/widgets/confetti-widget.dart';
import 'package:puzzle/widgets/control-buttons.dart';
import 'package:puzzle/widgets/grid-game-widget.dart';
import 'package:puzzle/widgets/path-indicator-widget.dart';
import 'package:puzzle/widgets/timer-level-widget.dart';
import 'package:puzzle/widgets/top-bar-widget.dart';

class GameScreen extends StatelessWidget {
  final PaternModel paternModel;

  const GameScreen({Key? key, required this.paternModel}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => GameViewModel(paternModel: paternModel),
//       child: Scaffold(
//         body: _GameScreenContent(),
//       ),
//     );
//   }
// }

// class _GameScreenContent extends StatelessWidget {

  // ConfettiController controllerCenterLeft =
  //     ConfettiController(duration: const Duration(seconds: 5));
  // ConfettiController controllerCenterRight =
  //     ConfettiController(duration: const Duration(seconds: 5));

  // final GameViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final playerStatsManager = Provider.of<PlayerStatsManager>(context);
    // final viewModel = Provider.of<GameViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final smallScreen = screenSize.shortestSide < 600;

    return Scaffold(
        body: ChangeNotifierProvider(
      create: (context) => GameViewModel(paternModel: paternModel, playerStatsManager: playerStatsManager),
      child: Consumer<GameViewModel>(
        builder: (context, viewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.win) {
              viewModel.handleWin(context);
            }
            if (viewModel.gameOver) {
              viewModel.handleGameOver(context);
            }
          });

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
              ),
            ),
            child: SafeArea(
              child: isPortrait
                  ? _widgetPortraitLayout(context, smallScreen)
                  : _widgetLandscapeLayout(context, smallScreen),
            ),
          );
        },
      ),
    ));
  }

  Widget _widgetPortraitLayout(BuildContext context, bool smallScreen) {
    final screenSize = MediaQuery.of(context).size;
    bool inRow = screenSize.width > screenSize.height * 0.7;
    return Column(
      children: [
        Topbarwidget(),
        Timerlevelwidget(),
        if (!inRow) ...[
          Controlbuttons(isPortrait: true),
          SizedBox(
            height: screenSize.height - screenSize.width > 400
                ? screenSize.width
                : screenSize.height - 400,
            child: Gridgamewidget(),
          )
        ],
        if (inRow) ...[
          Expanded(
            flex: 7,
            child: Row(
              children: [Gridgamewidget(), Controlbuttons(isPortrait: true)],
            ),
          ),
        ],
        PathindIcatorWidget(),
        Confettiwidget(
          // controllerCenterLeft: controllerCenterLeft,
          // controllerCenterRight: controllerCenterRight,
        ),
        Expanded(child: ActionButtonsWidget()),
        CommandsIndicatorWidget(),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _widgetLandscapeLayout(BuildContext context, bool smallScreen) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Topbarwidget(),
              Timerlevelwidget(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Controlbuttons(isPortrait: false),
                    PathindIcatorWidget(),
                    ActionButtonsWidget(),
                    CommandsIndicatorWidget(),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Gridgamewidget(),
              ),
              Confettiwidget(
                // controllerCenterLeft: controllerCenterLeft,
                // controllerCenterRight: controllerCenterRight,
              )
            ],
          ),
        ),
      ],
    );
  }
}
