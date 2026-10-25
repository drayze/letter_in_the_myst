import 'package:flutter/material.dart';

class CauldronFrameWidget extends StatelessWidget {
  final Widget child;

  const CauldronFrameWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0, // Ensures a perfectly round circular cauldron!
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Fiery Orangish-Red Glow Underneath Round Cauldron Base
                  Positioned(
                    bottom: -16,
                    left: 40,
                    right: 40,
                    height: 38,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          // Deep Red Core Glow
                          BoxShadow(
                            color: const Color(0xFFFF2A00).withAlpha(250),
                            blurRadius: 32,
                            spreadRadius: 10,
                          ),
                          // Bright Flame Orange Spread Glow
                          BoxShadow(
                            color: const Color(0xFFFF6D00).withAlpha(220),
                            blurRadius: 45,
                            spreadRadius: 16,
                          ),
                          // Amber Fire Aura
                          BoxShadow(
                            color: const Color(0xFFFFAB00).withAlpha(160),
                            blurRadius: 60,
                            spreadRadius: 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Left Cauldron Side Handle
                  Positioned(
                    left: -14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Right Cauldron Side Handle
                  Positioned(
                    right: -14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Black Round Cast-Iron Cauldron Pot
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      shape: BoxShape.circle, // 100% Round Cauldron!
                      border: Border.all(
                        color: const Color(0xFF3A3A3A),
                        width: 4.5,
                      ),
                      gradient: const RadialGradient(
                        center: Alignment(-0.2, -0.3),
                        radius: 0.95,
                        colors: [
                          Color(0xFF2E2E2E), // Metallic specular highlight
                          Color(0xFF1C1C1C),
                          Color(0xFF0A0A0A), // Deep black cauldron belly
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(220),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          // Dark Bubbling Magic Brew Interior
                          Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.85,
                                colors: [
                                  Color(0xFF3A0066), // Magic brew core
                                  Color(0xFF20003B),
                                  Color(0xFF0D001A), // Dark brew edge
                                ],
                              ),
                            ),
                          ),

                          // Top Metallic Rim Specular Reflection Arc
                          Positioned(
                            top: 8,
                            left: 30,
                            right: 30,
                            height: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // Cauldron Interior Contents (Letter & Empty Bubbles)
                          Positioned.fill(child: child),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Fire Pit Base Embers
        Container(
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3D00).withAlpha(200),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6D00).withAlpha(240),
                blurRadius: 16,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
