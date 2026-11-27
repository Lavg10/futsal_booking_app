import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBrandBanner extends StatelessWidget {
  const AppBrandBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 220,
  });

  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
            ),
          ),
          const Positioned(
            top: -48,
            right: -36,
            child: CircleAvatar(
              radius: 110,
              backgroundColor: Color(0x14FFFFFF),
            ),
          ),
          const Positioned(
            bottom: 24,
            left: -40,
            child: CircleAvatar(
              radius: 78,
              backgroundColor: Color(0x10FFFFFF),
            ),
          ),
          SafeArea(
            top: true,
            bottom: false,
            left: false,
            right: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: AppColors.primaryDark,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
