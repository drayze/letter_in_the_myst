import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlyingWordWidget extends StatefulWidget {
  final String word;
  final Offset startOffset;
  final Offset targetOffset;
  final VoidCallback onComplete;

  const FlyingWordWidget({
    super.key,
    required this.word,
    required this.startOffset,
    required this.targetOffset,
    required this.onComplete,
  });

  @override
  State<FlyingWordWidget> createState() => _FlyingWordWidgetState();
}

class _FlyingWordWidgetState extends State<FlyingWordWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 65),
    ]).animate(_animation);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 60),
    ]).animate(_animation);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = _animation.value;

        // X coordinate interpolates linearly
        final double currentX = widget.startOffset.dx +
            (widget.targetOffset.dx - widget.startOffset.dx) * progress;

        // Y coordinate includes a subtle arc mid-flight
        final double arcPeak = -40.0 * (1 - (2 * progress - 1) * (2 * progress - 1));
        final double currentY = widget.startOffset.dy +
            (widget.targetOffset.dy - widget.startOffset.dy) * progress +
            arcPeak;

        final double scale = _scaleAnimation.value;
        final double glow = _glowAnimation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scale,
              child: Material(
                color: Colors.transparent,
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      AppColors.purplePrimary,
                      AppColors.successContainer,
                      progress,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color.lerp(
                        AppColors.purpleBright,
                        AppColors.emerald,
                        progress,
                      )!,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.emerald.withAlpha((180 * glow).toInt()),
                        blurRadius: 18 * glow + 4,
                        spreadRadius: 3 * glow,
                      ),
                      BoxShadow(
                        color: AppColors.purpleBright
                            .withAlpha((140 * (1 - progress)).toInt()),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.word.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        width: 28,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            AppColors.surfaceDark,
                            AppColors.emeraldDark,
                            progress,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color.lerp(
                              AppColors.purplePrimary,
                              AppColors.emerald,
                              progress,
                            )!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.word[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
