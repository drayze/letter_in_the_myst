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
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Fiery Orangish-Red Glow Underneath Cauldron Base
              Positioned(
                bottom: -12,
                left: 30,
                right: 30,
                height: 36,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      // Deep Red Core Glow
                      BoxShadow(
                        color: const Color(0xFFFF2A00).withAlpha(240),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                      // Bright Flame Orange Spread Glow
                      BoxShadow(
                        color: const Color(0xFFFF6D00).withAlpha(200),
                        blurRadius: 40,
                        spreadRadius: 14,
                      ),
                      // Amber Fire Aura
                      BoxShadow(
                        color: const Color(0xFFFFAB00).withAlpha(150),
                        blurRadius: 55,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Black Cast-Iron Cauldron Body
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 3.5,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2C2C2C), // Metallic rim highlight
                      Color(0xFF1A1A1A),
                      Color(0xFF0F0F0F), // Deep black cauldron belly
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(200),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Dark Bubbling Magic Liquid Interior
                      Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.85,
                            colors: [
                              Color(0xFF3A0066), // Magic brew core
                              Color(0xFF20003B),
                              Color(0xFF0D001A), // Dark brew edges
                            ],
                          ),
                        ),
                      ),

                      // Metallic Rim Highlight Line
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(20),
                                Colors.white.withAlpha(100),
                                Colors.white.withAlpha(20),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Cauldron Interior Contents (Letters & Empty Bubbles)
                      Positioned.fill(child: child),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ember / Fire Pit Visual Base
        Container(
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3D00).withAlpha(180),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6D00).withAlpha(220),
                blurRadius: 14,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
