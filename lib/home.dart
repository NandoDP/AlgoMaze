// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:puzzle/game_page.dart';
import 'package:puzzle/paterns.dart';
import 'package:puzzle/player-model.dart';

class HomeScreen extends StatefulWidget {
  PlayerStats playerStats;
  HomeScreen({super.key, required this.playerStats});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlayerStats? _playerStats;
  bool firstTime = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerStats();
  }

  Future<void> _loadPlayerStats() async {
    _playerStats = await PlayerStatsManager.loadStats();
    firstTime = PlayerStatsManager.firstTime;
    setState(() {});
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  patern:
                                      paterns[_playerStats!.currentLevel - 1],
                                ),
                              ),
                            );
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

class LevelSelectionList extends StatelessWidget {
  final PlayerStats playerStats;
  const LevelSelectionList({
    super.key,
    required this.playerStats,
  });
  @override
  Widget build(BuildContext context) {
    final totalLevels = paterns.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12),
      itemCount: totalLevels,
      itemBuilder: (context, index) {
        final levelNumber = index + 1;
        final isCompleted = playerStats.completedLevels.contains(levelNumber);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: LevelCard(
            levelNumber: levelNumber,
            isCompleted: isCompleted,
          ),
        );
      },
    );
  }
}

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isCompleted;

  const LevelCard({
    Key? key,
    required this.levelNumber,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        startLevel(context, levelNumber);
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isCompleted ? Color(0xFF00CBA9) : Color(0xFF4A4A5A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$levelNumber',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (isCompleted)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
            if (!isCompleted)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            SizedBox(height: 8),
            Text(
              isCompleted ? 'Terminé' : 'Jouer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startLevel(BuildContext context, int levelNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(patern: paterns[levelNumber - 1]),
      ),
    );
  }
}

class StatsPanel extends StatelessWidget {
  final PlayerStats playerStats;
  final bool isSmallScreen;
  final bool isLargeScreen;

  StatsPanel({
    super.key,
    required this.isSmallScreen,
    required this.isLargeScreen,
    required this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isSmallScreen ? 12 : (isLargeScreen ? 18 : 14);
    final double titleSize = isSmallScreen ? 14 : (isLargeScreen ? 20 : 16);
    final double padding = isSmallScreen ? 15 : (isLargeScreen ? 30 : 20);
    final double spacing = isSmallScreen ? 15 : (isLargeScreen ? 25 : 20);

    return Container(
      padding: EdgeInsets.all(padding),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistiques de jeu',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Réinitialiser les données'),
                          content: Text(
                              'Êtes-vous sûr de vouloir supprimer toutes vos données et recommencer à zéro ? Cette action est irréversible.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: Text('Réinitialiser'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirmed) {
                    final success = await PlayerStatsManager.resetAllStats();

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Données réinitialisées avec succès')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Erreur lors de la réinitialisation des données')),
                      );
                    }
                  }
                },
                icon: Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          SizedBox(height: spacing),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveaux complétés:',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${playerStats.completedLevelsCount}/${paterns.length}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00CCAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          LinearPercentIndicator(
            animation: true,
            lineHeight: 7.0,
            animationDuration: 1000,
            percent: playerStats.completedLevelsCount / paterns.length,
            barRadius: const Radius.circular(5),
            progressColor: Colors.teal,
            backgroundColor: Colors.grey[800],
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: spacing),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temps de jeu total:',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey,
                ),
              ),
              Text(
                playerStats.formattedTotalPlayTime,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00CCAA),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Meilleur temps (niveau ${playerStats.bestTimeLevel}):',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                playerStats.formattedbestTime,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00CCAA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    final double gridSize = size.width / 20;

    // Lignes verticales
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Lignes horizontales
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
