part of 'leaderboard_bloc.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object> get props => [];
}

final class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(
      {required this.entries, required this.current, required this.finishTime});

  final List<LeaderboardEntryData> entries;
  final LeaderboardEntryData current;
  final DateTime finishTime;

  @override
  List<Object> get props => [entries, current, finishTime];
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError();
}
