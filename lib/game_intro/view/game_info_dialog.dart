import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:super_dash/gen/assets.gen.dart';

class GameInfoDialog extends StatelessWidget {
  const GameInfoDialog({super.key});

  static PageRoute<void> route() {
    return HeroDialogRoute(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const GameInfoDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.titleMedium;
    const highlightColor = Color(0xFF9CECCD);
    final linkStyle = AppTextStyles.titleSmall.copyWith(
      color: highlightColor,
      decorationColor: highlightColor,
    );
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
                Text(
                  'HỌC NHIỆT TÌNH CHƠI HẾT MÌNH',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: [
                    Assets.images.bear.image(width: 80),
                    Text(
                      'Top 20',
                      style: bodyStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Assets.images.bag.image(width: 80),
                        Text(
                          'Top 50',
                          style: bodyStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      children: [
                        Assets.images.hat.image(width: 80),
                        Text(
                          'Top 100',
                          style: bodyStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Thời gian đua top:',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Từ 04/11/2024 - 14/11/2024.',
                  style: linkStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Thời gian trao thưởng',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Từ 16/11/2024 - 17/11/2024',
                  style: linkStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Hình thức trao thưởng',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Trao quà trực tiếp tại Văn phòng Cambridge Mentor - A6 - 09 Khu đô thị Monbay.',
                  style: linkStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GameElevatedButton(
            label: 'Tiếp tục',
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
