import 'package:flutter/material.dart';

class GlitterBackground extends StatelessWidget {
  final Widget child;
  const GlitterBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D004E), Color(0xFF4B0082), Color(0xFF6A0DAD)],
        ),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.15,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.transparenttextures.com/patterns/stardust.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}