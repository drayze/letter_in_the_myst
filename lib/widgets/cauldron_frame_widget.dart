import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/themes.dart';

class CauldronFrameWidget extends StatelessWidget {
  final Widget child;

  const CauldronFrameWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = min(constraints.maxWidth, constraints.maxHeight);
        final double cauldronW = size;
        final double cauldronH = size;

        return Center(
          child: SizedBox(
            width: cauldronW,
            height: cauldronH,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Soft Fire Glow Wrapping 60% of the Cauldron (Layer 0: Behind Cauldron)
                Positioned(
                  bottom: -15,
                  width: cauldronW * 1.55, // Wraps around cauldron sides!
                  height: cauldronH * 0.88, // Wraps around lower 60% of cauldron height!
                  child: CustomPaint(
                    painter: CauldronFireGlowPainter(),
                  ),
                ),

                // 2. Left Cauldron Side Handle
                Positioned(
                  left: -12,
                  top: cauldronH * 0.40,
                  child: Container(
                    width: 24,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cauldronHandleBorder,
                        width: 4.5,
                      ),
                    ),
                  ),
                ),

                // 3. Right Cauldron Side Handle
                Positioned(
                  right: -12,
                  top: cauldronH * 0.40,
                  child: Container(
                    width: 24,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cauldronHandleBorder,
                        width: 4.5,
                      ),
                    ),
                  ),
                ),

                // 4. Black Round Cast-Iron Cauldron Pot
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cauldronDarkBase,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cauldronPotBorder,
                      width: 4.0,
                    ),
                    gradient: AppGradients.cauldronPot,
                    boxShadow: AppShadows.cauldronShadow,
                  ),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        // Dark Bubbling Magic Brew Interior
                        Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.magicBrew,
                          ),
                        ),

                        // Top Metallic Specular Rim Arc
                        Positioned(
                          top: 10,
                          left: 35,
                          right: 35,
                          height: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        // Cauldron Play Area (Letter Wheel & Lines)
                        Positioned.fill(child: child),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Paints soft fire glow wrapping around ~60% of the cauldron pot
class CauldronFireGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);

    final glowRadiusX = size.width * 0.48;
    final glowRadiusY = size.height * 0.46;

    // 1. Broad Outer Ambient Fire Glow (Wrapping 60% of Cauldron)
    final outerAuraRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 8),
      width: glowRadiusX * 2.1,
      height: glowRadiusY * 2.1,
    );

    final Paint outerAuraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.fireDeepRed.withAlpha(210), // Deep red-orange glow
          AppColors.fireWarmFlame.withAlpha(150), // Warm flame orange
          AppColors.fireCrimson.withAlpha(80),  // Crimson aura edge
          const Color(0xFF000000).withAlpha(0),   // 100% transparent fade!
        ],
        stops: const [0.0, 0.48, 0.78, 1.0],
      ).createShader(outerAuraRect);

    canvas.drawOval(outerAuraRect, outerAuraPaint);

    // 2. Inner Hot Fire Glow Body
    final innerGlowRect = Rect.fromCenter(
      center: center,
      width: glowRadiusX * 1.7,
      height: glowRadiusY * 1.7,
    );

    final Paint innerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.fireHotCore, // Hot white-yellow core
          AppColors.fireGoldenYellow, // Intense golden yellow
          AppColors.fireWarmFlame, // Blazing orange
          AppColors.fireDeepRed.withAlpha(190),
          const Color(0xFF000000).withAlpha(0),
        ],
        stops: const [0.0, 0.25, 0.55, 0.82, 1.0],
      ).createShader(innerGlowRect);

    canvas.drawOval(innerGlowRect, innerGlowPaint);

    // 3. Bright White-Hot Center Spot
    final coreSpotRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 4),
      width: glowRadiusX * 1.0,
      height: glowRadiusY * 0.65,
    );

    final Paint coreSpotPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha(245),
          AppColors.fireLightYellow.withAlpha(200),
          AppColors.fireWarmFlame.withAlpha(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(coreSpotRect);

    canvas.drawOval(coreSpotRect, coreSpotPaint);

    // 4. Rising Spark / Ember Particles floating around 60% of cauldron sides
    final rand = Random(42);
    final Paint emberPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 35; i++) {
      final angle = rand.nextDouble() * pi * 2;
      final dist = rand.nextDouble() * glowRadiusX * 0.90;
      final emberX = center.dx + cos(angle) * dist;
      final emberY = center.dy - rand.nextDouble() * size.height * 0.65;
      final emberRadius = 1.5 + rand.nextDouble() * 3.0;

      emberPaint.color = Color.lerp(
        AppColors.fireGoldenYellow,
        AppColors.fireDeepRed,
        rand.nextDouble(),
      )!.withAlpha((180 + rand.nextInt(75)));

      canvas.drawCircle(Offset(emberX, emberY), emberRadius, emberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
