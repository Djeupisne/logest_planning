import 'package:flutter/material.dart';

/// Widget de skeleton loading avec effet shimmer
/// Utilisé pour améliorer l'UX pendant le chargement des données
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                isDark ? Colors.grey[800]! : Colors.grey[300]!,
                isDark ? Colors.grey[700]! : Colors.grey[100]!,
                isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ],
              stops: [
                0.0,
                (_animation.value + 2) / 4,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton pour une carte de mission
class MissionCardSkeleton extends StatelessWidget {
  const MissionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerLoading(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLoading(width: 180, height: 18),
                      const SizedBox(height: 8),
                      const ShimmerLoading(width: 120, height: 14),
                    ],
                  ),
                ),
                const ShimmerLoading(width: 70, height: 28, borderRadius: BorderRadius.all(Radius.circular(14))),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerLoading(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 200, height: 12),
            const SizedBox(height: 16),
            Row(
              children: [
                const ShimmerLoading(width: 100, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
                const SizedBox(width: 8),
                const ShimmerLoading(width: 100, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton pour une liste de consultants
class ConsultantListSkeleton extends StatelessWidget {
  final int itemCount;

  const ConsultantListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (_, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const ShimmerLoading(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
          title: const ShimmerLoading(width: 150, height: 18),
          subtitle: const ShimmerLoading(width: 120, height: 14),
          trailing: const ShimmerLoading(width: 80, height: 28, borderRadius: BorderRadius.all(Radius.circular(14))),
        ),
      ),
    );
  }
}

/// Skeleton pour le planning hebdomadaire
class WeeklyPlanningSkeleton extends StatelessWidget {
  const WeeklyPlanningSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // En-tête des jours
          Row(
            children: [
              const SizedBox(width: 120),
              ...List.generate(5, (index) => const SizedBox(
                width: 140,
                child: ShimmerLoading(width: 140, height: 40, borderRadius: BorderRadius.all(Radius.circular(8))),
              )),
            ],
          ),
          const SizedBox(height: 12),
          // Lignes des consultants
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const ShimmerLoading(width: 120, height: 70),
                ...List.generate(5, (day) => const SizedBox(
                  width: 140,
                  child: ShimmerLoading(width: 140, height: 70, borderRadius: BorderRadius.all(Radius.circular(8))),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Widget de barre de progression circulaire animée
class AnimatedProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color? color;
  final String? label;

  const AnimatedProgressIndicator({
    super.key,
    required this.progress,
    this.size = 120,
    this.color,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.colorScheme.primary;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de fond
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 10,
              backgroundColor: primaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.2)),
            ),
          ),
          // Cercle de progression
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Label central
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) Text(label!, style: theme.textTheme.bodyMedium),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge de notification animé
class AnimatedBadge extends StatefulWidget {
  final Widget child;
  final int count;
  final bool show;
  final Color? color;

  const AnimatedBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.show = true,
    this.color,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    if (widget.show && widget.count > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && widget.count > 0 && !oldWidget.show) {
      _controller.forward();
    } else if (!widget.show || widget.count == 0) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.show && widget.count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.color ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  widget.count > 99 ? '99+' : widget.count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
