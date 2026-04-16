import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable logo widget. Use [dark] = true on dark backgrounds (landing page),
/// false on light backgrounds (app bar, etc.).
class AppLogo extends StatelessWidget {
  final double size;
  final bool dark;

  const AppLogo({super.key, this.size = 80, this.dark = true});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? Colors.white.withValues(alpha: 0.08) : AppTheme.greenPale;
    final ring = dark ? Colors.white.withValues(alpha: 0.14) : AppTheme.greenLight.withValues(alpha: 0.35);
    final core = dark ? AppTheme.greenBright : AppTheme.greenMid;
    final iconColor = Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          ),
          // Middle ring
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
          ),
          // Core circle
          Container(
            width: size * 0.54,
            height: size * 0.54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: core,
              boxShadow: [
                BoxShadow(
                  color: core.withValues(alpha: 0.45),
                  blurRadius: size * 0.18,
                  spreadRadius: size * 0.02,
                ),
              ],
            ),
          ),
          // Water drop icon
          Positioned(
            top: size * 0.255,
            left: size * 0.285,
            child: Icon(Icons.water_drop, size: size * 0.22, color: iconColor),
          ),
          // Leaf overlay (top-right of drop)
          Positioned(
            top: size * 0.22,
            left: size * 0.44,
            child: Icon(Icons.eco, size: size * 0.16, color: iconColor.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
