import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:super_dash/gen/assets.gen.dart';

class GameFinishDialog extends StatelessWidget {
  const GameFinishDialog({super.key});

  static PageRoute<void> route() {
    return HeroDialogRoute(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const GameFinishDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = AppTextStyles.titleSmall.copyWith(fontSize: 24);
    return AppDialog(
      showCloseButton: false,
      border: Border.all(color: Colors.white24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Assets.images.dashWins.image(width: 160),
                const SizedBox(height: 4),
                Text(
                  'Đã hết thời gian diễn ra chương trình',
                  style: linkStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GameElevatedButton(
            label: 'Đóng',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
