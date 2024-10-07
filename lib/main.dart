import 'dart:async'; 
import 'package:flutter/widgets.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:super_dash/app/app.dart';
import 'package:super_dash/audio/audio.dart';
import 'package:super_dash/bootstrap.dart'; 
import 'package:super_dash/settings/persistence/persistence.dart';
import 'package:super_dash/settings/settings.dart';
import 'package:super_dash/share/share.dart';

final leaderboardRepository = LeaderboardRepository();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  final settings = SettingsController(
    persistence: LocalStorageSettingsPersistence(),
  );

  final audio = AudioController()..attachSettings(settings);

  await audio.initialize();

  final share = ShareController(
    gameUrl: 'https://endless-runner-9481713-383737.web.app/',
  );

  unawaited(
    bootstrap(
      () async {
        return App(
          audioController: audio,
          settingsController: settings,
          shareController: share,
          leaderboardRepository: leaderboardRepository,
        );
      },
    ),
  );
}
