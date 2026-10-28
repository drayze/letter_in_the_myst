import 'dart:ui';
import 'package:flutter/material.dart';

class FlyingTileData {
  final String letter;
  final Offset startPos;
  final Offset endPos;
  final Color color;

  FlyingTileData({
    required this.letter,
    required this.startPos,
    required this.endPos,
    required this.color,
  });
}

class FlyingTileWidget extends StatelessWidget {
  final FlyingTileData data;
  final double progress; // 0.0 -> 1.0
  final double initialSize;

  const FlyingTileWidget({
    super.key,
    required this.data,
    required this.progress,
    this.initialSize = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final currentPos = Offset.lerp(data.startPos, data.endPos, progress)!;
    final scale = lerpDouble(1.15, 0.65, progress)!;
    final size = initialSize * scale;

    return Positioned(
      left: currentPos.dx - (size / 2),
      top: currentPos.dy - (size / 2),
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: data.color.withAlpha((220 * (1.0 - progress * 0.2)).toInt()),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: data.color.withAlpha(200),
                blurRadius: 16 * (1.0 - progress * 0.3),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              data.letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.48,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlyingTilesOverlay extends StatefulWidget {
  final List<FlyingTileData> tilesData;
  final VoidCallback onComplete;
  final Duration duration;

  const FlyingTilesOverlay({
    super.key,
    required this.tilesData,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  State<FlyingTilesOverlay> createState() => _FlyingTilesOverlayState();
}

class _FlyingTilesOverlayState extends State<FlyingTilesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

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
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        return Stack(
          children: widget.tilesData.map((data) {
            return FlyingTileWidget(
              data: data,
              progress: progress,
            );
          }).toList(),
        );
      },
    );
  }
}
