import 'package:flutter/material.dart';
import 'package:puzzle/veiws/game-view.dart';
import 'package:puzzle/providers/navigation-service.dart';
import 'package:puzzle/providers/player-stats-service.dart';

// import 'package:puzzle/game-page.dart';
import 'package:puzzle/paterns.dart';
import 'package:puzzle/widgets/grid-paint.dart';
import 'package:puzzle/widgets/level-selection-list.dart';
import 'package:puzzle/widgets/stats-panel.dart';

class HomeScreen extends StatefulWidget {
  PlayerStats playerStats;
  HomeScreen({super.key, required this.playerStats});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlayerStats? _playerStats;
  bool firstTime = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadPlayerStats();
  // }

  Future<void> _loadPlayerStats() async {
    _playerStats = await PlayerStatsManager.loadStats();
    firstTime = PlayerStatsManager.firstTime;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPlayerStats();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final bool isLargeScreen = screenSize.width > 600;

    // Responsive dimensions
    final double logoSize = isSmallScreen ? 45 : (isLargeScreen ? 80 : 56);
    final double titleSize = isSmallScreen ? 28 : (isLargeScreen ? 40 : 32);
    final double subtitleSize = isSmallScreen ? 12 : (isLargeScreen ? 18 : 14);
    final double buttonWidth =
        isSmallScreen ? 100 : (isLargeScreen ? 180 : 120);
    final double buttonHeight = isSmallScreen ? 40 : (isLargeScreen ? 60 : 50);
    final double buttonTextSize =
        isSmallScreen ? 16 : (isLargeScreen ? 22 : 18);
    final double topPadding = screenSize.height * 0.08;
    final double spacing = screenSize.height * 0.03;

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
          child: Stack(
            children: [
              CustomPaint(
                size: Size(screenSize.width, screenSize.height),
                painter: GridPainter(),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height,
                    maxWidth: screenSize.width,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: topPadding),

                        // Title
                        Text(
                          'CODE PATH',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00CCAA),
                            shadows: const [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black45,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          'Apprendre à programmer en s\'amusant',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: spacing * 2),

                        // Game logo
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00CCAA),
                            borderRadius:
                                BorderRadius.circular(logoSize * 0.09),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Diamond shape
                              Transform.rotate(
                                angle: 45 * 3.14159 / 180,
                                child: Container(
                                  width: logoSize * 0.7,
                                  height: logoSize * 0.7,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),

                              // Center dot
                              Container(
                                width: logoSize * 0.18,
                                height: logoSize * 0.18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: spacing * 2),

                        // Play button
                        ElevatedButton(
                          onPressed: () {
                            NavigationService.navigateTo(GameScreen(
                              paternModel:
                                  paterns[_playerStats!.currentLevel - 1],
                            ));
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => GameScreen(
                            //       paternModel:
                            //           paterns[_playerStats!.currentLevel - 1],
                            //     ),
                            //   ),
                            // );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00CCAA),
                            foregroundColor: const Color(0xFF1A1A2E),
                            minimumSize: Size(buttonWidth, buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonHeight / 2),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            firstTime ? 'Commencer' : 'Continuer',
                            style: TextStyle(
                              fontSize: buttonTextSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: spacing),

                        ElevatedButton(
                          onPressed: () {
                            showLevelSelectionModal(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF444444),
                            foregroundColor: Colors.white,
                            minimumSize: Size(buttonWidth, buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonHeight / 2),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Nouvelle Partie',
                            style: TextStyle(
                              fontSize: buttonTextSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 35),
                        StatsPanel(
                          isSmallScreen: isSmallScreen,
                          isLargeScreen: isLargeScreen,
                          playerStats: _playerStats ?? widget.playerStats,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLevelSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sélectionner un niveau',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: LevelSelectionList(
                  playerStats: _playerStats!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
