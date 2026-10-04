import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

/// Bottom splash loading label and animated progress bar.
class SplashLoadingSection extends StatefulWidget {
  const SplashLoadingSection({
    required this.barWidth,
    this.duration = const Duration(seconds: 4),
    this.onComplete,
    super.key,
  });

  final double barWidth;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<SplashLoadingSection> createState() => _SplashLoadingSectionState();
}

class _SplashLoadingSectionState extends State<SplashLoadingSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward().whenComplete(() {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return SplashProgressBar(
              width: widget.barWidth,
              progress: _progress.value,
            );
          },
        ),
      ],
    );
  }
}

/// Horizontal rounded progress indicator for the splash screen.
class SplashProgressBar extends StatelessWidget {
  const SplashProgressBar({
    required this.width,
    required this.progress,
    super.key,
  });

  final double width;
  final double progress;

  static const double height = 7;

  static const Color fillColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final fillWidth = width * clamped;
    final radius = BorderRadius.circular(height / 2);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.22),
          width: 0.75,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            const ColoredBox(color: Colors.white),
            if (fillWidth > 0)
              SizedBox(
                width: fillWidth,
                height: height,
                child: const ColoredBox(color: fillColor),
              ),
          ],
        ),
      ),
    );
  }
}
