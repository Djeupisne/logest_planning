import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/morning_briefing.dart';
import '../../core/services/haptic_service.dart';

/// Widget d'affichage du Morning Briefing quotidien
/// Présente un résumé complet de la journée du consultant
class MorningBriefingWidget extends StatefulWidget {
  final MorningBriefing briefing;
  final VoidCallback? onNavigateToMission;
  final VoidCallback? onStartDay;

  const MorningBriefingWidget({
    Key? key,
    required this.briefing,
    this.onNavigateToMission,
    this.onStartDay,
  }) : super(key: key);

  @override
  State<MorningBriefingWidget> createState() => _MorningBriefingWidgetState();
}

class _MorningBriefingWidgetState extends State<MorningBriefingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final HapticService _hapticService = HapticService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    _hapticService.notification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = widget.briefing.readiness == BriefingReadiness.ready;
    final needsAttention = widget.briefing.readiness == BriefingReadiness.attention;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec salutation
            _buildHeader(theme),
            const SizedBox(height: 16),

            // Statut de préparation
            _buildReadinessCard(theme, isReady, needsAttention),
            const SizedBox(height: 16),

            // Messages contextuels (météo, trafic, etc.)
            if (widget.briefing.contextualMessages.isNotEmpty) ...[
              _buildContextualMessages(theme),
              const SizedBox(height: 16),
            ],

            // Statistiques clés
            _buildStatsRow(theme),
            const SizedBox(height: 16),

            // Timeline des missions
            _buildMissionsTimeline(theme),
            const SizedBox(height: 16),

            // Citation motivante
            _buildMotivationalQuote(theme),
            const SizedBox(height: 16),

            // Bouton d'action
            _buildActionButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final format = DateFormat('EEEE d MMMM', 'fr_FR');
    final hour = DateTime.now().hour;
    
    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting ${widget.briefing.consultantName.split(' ').first}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format.format(widget.briefing.date),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.briefing.totalMissions} mission${widget.briefing.totalMissions > 1 ? 's' : ''}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessCard(ThemeData theme, bool isReady, bool needsAttention) {
    Color cardColor;
    IconData icon;
    String text;
    
    if (isReady) {
      cardColor = Colors.green;
      icon = Icons.check_circle_outline;
      text = 'Tout est prêt pour aujourd\'hui';
    } else if (needsAttention) {
      cardColor = Colors.orange;
      icon = Icons.info_outline;
      text = '${widget.briefing.urgentMissionsCount} mission(s) urgente(s) à noter';
    } else {
      cardColor = Colors.red;
      icon = Icons.warning_outline;
      text = 'Informations manquantes';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        border: Border.all(color: cardColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: cardColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualMessages(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À savoir aujourd\'hui',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.briefing.contextualMessages.map((message) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            label: 'Temps de travail',
            value: _formatDuration(widget.briefing.totalWorkTime),
            color: Colors.blue,
            hapticService: _hapticService,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_car,
            label: 'Distance estimée',
            value: '${widget.briefing.totalDistanceKm.toStringAsFixed(1)} km',
            color: Colors.green,
            hapticService: _hapticService,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer,
            label: 'Temps de trajet',
            value: _formatDuration(widget.briefing.estimatedTravelTime),
            color: Colors.orange,
            hapticService: _hapticService,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionsTimeline(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vos missions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.briefing.missions.length > 3)
              TextButton(
                onPressed: () {
                  _hapticService.lightClick();
                  widget.onNavigateToMission?.call();
                },
                child: const Text('Voir tout'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.briefing.missions.take(3).map((mission) {
          return _MissionTile(
            mission: mission,
            onTap: () {
              _hapticService.mediumTap();
              widget.onNavigateToMission?.call();
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMotivationalQuote(ThemeData theme) {
    if (widget.briefing.motivationalQuote == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.briefing.motivationalQuote!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          _hapticService.success();
          widget.onStartDay?.call();
        },
        icon: const Icon(Icons.play_arrow, size: 24),
        label: Text(
          'Commencer ma journée',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

/// Carte statistique
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final HapticService hapticService;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.hapticService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hapticService.lightClick(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tuile de mission dans la timeline
class _MissionTile extends StatelessWidget {
  final MissionSummary mission;
  final VoidCallback onTap;

  const _MissionTile({
    required this.mission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(mission.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(mission.status),
            color: _getStatusColor(mission.status),
            size: 20,
          ),
        ),
        title: Text(
          mission.clientName,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(mission.location, style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              mission.formattedTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: mission.isUrgent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  IconData _getStatusIcon(MissionStatus status) {
    switch (status) {
      case MissionStatus.scheduled:
        return Icons.schedule;
      case MissionStatus.enRoute:
        return Icons.directions_car;
      case MissionStatus.arrived:
        return Icons.check_circle;
      case MissionStatus.inProgress:
        return Icons.play_circle;
      case MissionStatus.completed:
        return Icons.done_all;
      case MissionStatus.cancelled:
        return Icons.cancel;
      case MissionStatus.problem:
        return Icons.warning;
    }
  }

  Color _getStatusColor(MissionStatus status) {
    switch (status) {
      case MissionStatus.scheduled:
        return Colors.blue;
      case MissionStatus.enRoute:
        return Colors.orange;
      case MissionStatus.arrived:
        return Colors.green;
      case MissionStatus.inProgress:
        return Colors.purple;
      case MissionStatus.completed:
        return Colors.teal;
      case MissionStatus.cancelled:
        return Colors.grey;
      case MissionStatus.problem:
        return Colors.red;
    }
  }
}
