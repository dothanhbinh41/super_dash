import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

part 'score_event.dart';
part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  ScoreBloc({
    required this.score,
    required LeaderboardRepository leaderboardRepository,
  })  : _leaderboardRepository = leaderboardRepository,
        super(ScoreState()) {
    on<ScoreSubmitted>(_onScoreSubmitted);
    on<ScoreInitialsUpdated>(_onScoreInitialsUpdated);
    on<ScoreInitialsSubmitted>(_onScoreInitialsSubmitted);
    on<ScoreLeaderboardRequested>(_onScoreLeaderboardRequested);
    on<ScoreGoHomeRequested>(_onGoHomeRequested);
  }

  final int score;
  final LeaderboardRepository _leaderboardRepository;

  final initialsRegex = RegExp('[0-9]+');

  void _onScoreSubmitted(
    ScoreSubmitted event,
    Emitter<ScoreState> emit,
  ) {
    emit(
      state.copyWith(
        status: ScoreStatus.inputInitials,
      ),
    );
  }

  void _onScoreInitialsUpdated(
    ScoreInitialsUpdated event,
    Emitter<ScoreState> emit,
  ) {
    state.initials = event.character;
    final initialsStatus =
        (state.initialsStatus == InitialsFormStatus.blacklisted)
            ? InitialsFormStatus.initial
            : state.initialsStatus;
    emit(
      state.copyWith(initials: state.initials, initialsStatus: initialsStatus),
    );
  }

  Future<void> _onScoreInitialsSubmitted(
    ScoreInitialsSubmitted event,
    Emitter<ScoreState> emit,
  ) async {
    await _leaderboardRepository.addLeaderboardEntry(score);

    // emit(state.copyWith(status: ScoreStatus.scoreOverview));
  }

  bool _hasValidPattern() {
    final value = state.initials;
    final res = value.isNotEmpty && initialsRegex.hasMatch(value);
    return res;
  }

  bool _isInitialsBlacklisted() {
    return _blacklist.contains(state.initials);
  }

  void _onScoreLeaderboardRequested(
    ScoreLeaderboardRequested event,
    Emitter<ScoreState> emit,
  ) {
    emit(
      state.copyWith(
        status: ScoreStatus.leaderboard,
      ),
    );
  }

  void _onGoHomeRequested(
    ScoreGoHomeRequested event,
    Emitter<ScoreState> emit,
  ) {
    emit(
      state.copyWith(
        status: ScoreStatus.goHome,
      ),
    );
  }
}

const _blacklist = [
  'FUK',
  'FUC',
  'COK',
  'DIK',
  'KKK',
  'SHT',
  'CNT',
  'ASS',
  'CUM',
  'FAG',
  'GAY',
  'GOD',
  'JEW',
  'SEX',
  'TIT',
  'WTF',
];
