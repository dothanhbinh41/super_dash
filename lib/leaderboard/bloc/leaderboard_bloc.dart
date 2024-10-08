import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({
    required LeaderboardRepository leaderboardRepository,
  })  : _leaderboardRepository = leaderboardRepository,
        super(const LeaderboardInitial()) {
    on<LeaderboardTop10Requested>(_onLeaderboardRequested);
  }

  final LeaderboardRepository _leaderboardRepository;

  Future<void> _onLeaderboardRequested(
    LeaderboardTop10Requested event,
    Emitter<LeaderboardState> emit,
  ) async {
    try {
      emit(const LeaderboardLoading());
      final leaderboard = await _leaderboardRepository.fetchTop10Leaderboard();
      final currentTop = await _leaderboardRepository.getCurrentTop();
      final finishTime = await _leaderboardRepository.getFinishTime();
      emit(LeaderboardLoaded(
          entries: leaderboard, current: currentTop, finishTime: finishTime));
    } catch (e) {
      emit(const LeaderboardError());
    }
  }
}
