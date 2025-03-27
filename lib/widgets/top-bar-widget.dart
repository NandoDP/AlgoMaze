import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/models/game-viewmodel.dart';
import 'package:puzzle/providers/navigation-service.dart';
import 'package:puzzle/veiws/home.dart';

class Topbarwidget extends StatefulWidget {
  const Topbarwidget({super.key});

  @override
  _TopbarwidgetState createState() => _TopbarwidgetState();
}

class _TopbarwidgetState extends State<Topbarwidget> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (viewModel.gameOver) {
    //     showDialog(
    //       context: context,
    //       barrierDismissible: false,
    //       builder: (BuildContext context) => GameOverDialog(),
    //     );
    //     // viewModel.markDialogShown();
    //   } else if (viewModel.win) {
    //     showDialog(
    //       context: context,
    //       barrierDismissible: false,
    //       builder: (BuildContext context) => WinDialogWidget(),
    //     );
    //     // viewModel.markDialogShown();
    //   }
    // });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              NavigationService.navigateReplacementTo(HomeScreen(
                // playerStats: viewModel.playerStats,
              ));
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => HomeScreen(
              //       playerStats: viewModel.playerStats,
              //     ),
              //   ),
              // );
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
                value: viewModel.timeRemaining /
                    viewModel.paternModel.timeRemaining,
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
