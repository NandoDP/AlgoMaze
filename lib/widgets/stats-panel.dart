import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:puzzle/providers/player-stats-service.dart';
import 'package:puzzle/paterns.dart';

class StatsPanel extends StatefulWidget {
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
  State<StatsPanel> createState() => _StatsPanelState();
}

class _StatsPanelState extends State<StatsPanel> {
  @override
  Widget build(BuildContext context) {
    final double fontSize =
        widget.isSmallScreen ? 12 : (widget.isLargeScreen ? 18 : 14);
    final double titleSize =
        widget.isSmallScreen ? 14 : (widget.isLargeScreen ? 20 : 16);
    final double padding =
        widget.isSmallScreen ? 15 : (widget.isLargeScreen ? 30 : 20);
    final double spacing =
        widget.isSmallScreen ? 15 : (widget.isLargeScreen ? 25 : 20);

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
                    setState(() {});

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Données réinitialisées avec succès'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Erreur lors de la réinitialisation des données'),
                        ),
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
                '${widget.playerStats.completedLevelsCount}/${paterns.length}',
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
            percent: widget.playerStats.completedLevelsCount / paterns.length,
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
                widget.playerStats.formattedTotalPlayTime,
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
                  'Meilleur temps (niveau ${widget.playerStats.bestTimeLevel}):',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                widget.playerStats.formattedbestTime,
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
