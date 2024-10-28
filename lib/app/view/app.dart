import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:super_dash/app_lifecycle/app_lifecycle.dart';
import 'package:super_dash/audio/audio.dart';
import 'package:super_dash/game_intro/game_intro.dart';
import 'package:super_dash/l10n/l10n.dart';
import 'package:super_dash/settings/settings.dart';
import 'package:super_dash/share/share.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  const App({
    required this.audioController,
    required this.settingsController,
    required this.shareController,
    required this.leaderboardRepository,
    this.isTesting = false,
    super.key,
  });

  final bool isTesting;
  final AudioController audioController;
  final SettingsController settingsController;
  final ShareController shareController;
  final LeaderboardRepository leaderboardRepository;

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AudioController>(
            create: (context) {
              final lifecycleNotifier =
                  context.read<ValueNotifier<AppLifecycleState>>();
              return audioController
                ..attachLifecycleNotifier(lifecycleNotifier);
            },
            lazy: false,
          ),
          RepositoryProvider<SettingsController>.value(
            value: settingsController,
          ),
          RepositoryProvider<ShareController>.value(
            value: shareController,
          ),
          RepositoryProvider<LeaderboardRepository>.value(
            value: leaderboardRepository,
          ),
        ],
        child: ToastificationWrapper(
            child: MaterialApp(
          theme: ThemeData(
            textTheme: AppTextStyles.textTheme,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const GameIntroPage(),
          locale: const Locale.fromSubtags(languageCode: 'vi'),
          debugShowCheckedModeBanner: false,
        )),
      ),
    );
  }
}
