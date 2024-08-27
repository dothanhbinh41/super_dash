import 'package:flutter/material.dart';
import 'package:super_dash/game_intro/game_intro.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AudioButton(),
            InfoButton(),
          ],
        ),
      ),
    );
  }
}
