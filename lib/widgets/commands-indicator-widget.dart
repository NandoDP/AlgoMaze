import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/utils/actions.dart';

class CommandsIndicatorWidget extends StatelessWidget {
  const CommandsIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final smallScreen = screenSize.shortestSide < 600;
    final buttonSize = smallScreen ? 36.0 : 45.0;
    final iconSize = smallScreen ? 20.0 : 24.0;

    return Container(
      height: (buttonSize + 16) * (viewModel.paternModel.steps1 != null ? 2 : 1),
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            _buildActionRow(
              viewModel, 
              buttonSize, 
              iconSize, 
              viewModel.firstActions, 
              viewModel.paternModel.steps0, 
              isFirstStage: true
            ),
            if (viewModel.paternModel.steps1 != null)
              _buildActionRow(
                viewModel, 
                buttonSize, 
                iconSize, 
                viewModel.secondActions, 
                viewModel.paternModel.steps1!, 
                isFirstStage: false
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
    GameViewModel viewModel, 
    double buttonSize, 
    double iconSize, 
    List<List<dynamic>> actions, 
    int maxSteps, 
    {required bool isFirstStage}
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Stage indicator
        _buildStageIndicator(buttonSize, iconSize, isFirstStage),
        
        // Added actions
        ...actions.map((action) => _buildActionContainer(
          buttonSize, 
          iconSize, 
          action[0], 
          action[1]
        )),
        
        // Empty slots
        ...List.generate(
          maxSteps - actions.length, 
          (_) => _buildEmptyActionContainer(buttonSize)
        ),
      ],
    );
  }

  Widget _buildStageIndicator(double buttonSize, double iconSize, bool isFirstStage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Icon(
          isFirstStage 
            ? Icons.exposure_zero_rounded 
            : Icons.one_x_mobiledata_rounded,
          color: Colors.white, 
          size: iconSize
        ),
      ),
    );
  }

  Widget _buildActionContainer(
    double buttonSize, 
    double iconSize, 
    dynamic actionType, 
    Color actionColor
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: actionColor != Colors.grey 
            ? actionColor 
            : Colors.grey.shade800,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Icon(
          getIconData(actionType),
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildEmptyActionContainer(double buttonSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}
