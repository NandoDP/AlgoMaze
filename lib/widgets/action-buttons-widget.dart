import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-model.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/utils/actions.dart';

class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final smallScreen = screenSize.shortestSide < 600;
    final buttonSize = smallScreen ? 36.0 : 45.0;
    final iconSize = smallScreen ? 20.0 : 30.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var button in viewModel.paternModel.buttons)
                  Builder(
                    builder: (context) {
                      bool colorSelected = button is Color && button == viewModel.selectedColor;
                      return InkWell(
                        onTap: () {
                          _handleButtonTap(context, button, colorSelected);
                        },
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          decoration: BoxDecoration(
                            color: button is Color ? button : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(5),
                            border: colorSelected
                                ? Border.all(color: Colors.white)
                                : null,
                          ),
                          child: button is Color
                              ? null
                              : Icon(
                                  getIconData(button),
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleButtonTap(BuildContext context, dynamic button, bool colorSelected) {
    final viewModel = Provider.of<GameViewModel>(context, listen: false);
    
    if (viewModel.firstActions.length < viewModel.paternModel.steps0) {
      _handleFirstStageActions(viewModel, button, colorSelected);
    } else if (viewModel.paternModel.steps1 != null) {
      _handleSecondStageActions(viewModel, button, colorSelected);
    }
  }

  void _handleFirstStageActions(GameViewModel viewModel, dynamic button, bool colorSelected) {
    if (button is Color) {
      viewModel.setColor(button);
    } else {
      _addActionToList(viewModel, viewModel.firstActions, button);
    }
  }

  void _handleSecondStageActions(GameViewModel viewModel, dynamic button, bool colorSelected) {
    if (viewModel.secondActions.length < viewModel.paternModel.steps1!) {
      if (button is Color) {
        viewModel.setColor(button);
      } else {
        _addActionToList(viewModel, viewModel.secondActions, button);
      }
    }
  }

  void _addActionToList(GameViewModel viewModel, List<List<dynamic>> actionList, dynamic button) {
    if (button == Move.repetStage0 || button == Move.repetStage1) {
      actionList.add([button, viewModel.selectedColor ?? Colors.grey]);
      viewModel.setColor(null);
    } else {
      actionList.add([button, viewModel.selectedColor ?? Colors.grey]);
      viewModel.setColor(null);
    }
  }
}
