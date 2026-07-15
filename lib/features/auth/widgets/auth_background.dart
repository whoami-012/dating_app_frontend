import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget? child;

  const AuthBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_background.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0.10, -0.45),
            errorBuilder: (context, error, stackTrace) {
              // Fallback solid color container with subtle pattern if asset fails to load
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF020617)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white24,
                    size: 64,
                  ),
                ),
              );
            },
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
