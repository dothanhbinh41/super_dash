part of 'score_bloc.dart';

enum ScoreStatus {
  gameOver,
  inputInitials,
  scoreOverview,
  leaderboard,
  goHome,
}

enum InitialsFormStatus {
  initial,
  loading,
  success,
  invalid,
  failure,
  blacklisted,
}

// ignore: must_be_immutable
class ScoreState extends Equatable {
  ScoreState({
    this.status = ScoreStatus.gameOver,
    this.initials = '',
    this.initialsStatus = InitialsFormStatus.initial,
  });

  final ScoreStatus status;
  String initials;
  final InitialsFormStatus initialsStatus;

  ScoreState copyWith({
    ScoreStatus? status,
    String? initials,
    InitialsFormStatus? initialsStatus,
  }) {
    return ScoreState(
      status: status ?? this.status,
      initials: initials ?? this.initials,
      initialsStatus: initialsStatus ?? this.initialsStatus,
    );
  }

  @override
  List<Object> get props => [status, initials, initialsStatus];
}
