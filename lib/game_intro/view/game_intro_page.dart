import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:super_dash/game_intro/game_intro.dart';
import 'package:super_dash/game_intro/view/game_finish_dialog.dart';
import 'package:super_dash/game_intro/view/game_info_input_dialog.dart';
import 'package:super_dash/gen/assets.gen.dart';
import 'package:super_dash/l10n/l10n.dart';
import 'package:super_dash/main.dart';

class GameIntroPage extends StatefulWidget {
  const GameIntroPage({super.key});
  static PageRoute<void> route() {
    return HeroDialogRoute(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const GameIntroPage(),
      ),
    );
  }

  static Page<void> page() {
    return const MaterialPage(
      child: GameIntroPage(),
    );
  }

  @override
  State<GameIntroPage> createState() => _GameIntroPageState();
}

class _GameIntroPageState extends State<GameIntroPage> {
  DateTime? finishTime;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(Assets.images.gameBackground.provider(), context);
  }

  Future<void> loadFinishTime() async {
    final time = await leaderboardRepository.getFinishTime();
    setState(() {
      finishTime = time;
    });
    if (DateTime.now().isBefore(time)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(GameInfoDialog.route());
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(GameFinishDialog.route());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadFinishTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: context.isSmall
                ? Assets.images.introBackgroundMobile.provider()
                : Assets.images.introBackgroundDesktop.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: _IntroPage(
          finishTime: finishTime,
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({this.finishTime});
  final DateTime? finishTime;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Column(
          children: [
            const Spacer(),
            Assets.images.gameLogo.image(
              width: context.isSmall ? 282 : 380,
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.gameIntroPageHeadline,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Visibility(
              child: GameElevatedButton(
                label: l10n.gameIntroPagePlayButtonText,
                onPressed: () {
                  Navigator.of(context).push(GameInfoInputDialog.route());
                  // Navigator.of(context).push(Game.route());
                },
              ),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AudioButton(),
                LeaderboardButton(),
                InfoButton(),
                HowToPlayButton(),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
