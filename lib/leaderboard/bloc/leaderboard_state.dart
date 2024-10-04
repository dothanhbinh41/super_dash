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
  const LeaderboardLoaded({required this.entries, required this.current});

  final List<LeaderboardEntryData> entries;
  final LeaderboardEntryData current;

  @override
  List<Object> get props => [entries, current];
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError();
}
