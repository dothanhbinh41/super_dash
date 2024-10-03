// ignore_for_file: avoid_field_initializers_in_const_classes, avoid_dynamic_calls, omit_local_variable_types

import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:leaderboard_repository/src/leaderboard_api.dart';
import 'package:leaderboard_repository/src/models/get_leaderboard_dto.dart';

/// {@template leaderboard_repository}
/// Repository to access leaderboard data in Firebase Cloud Firestore.
/// {@endtemplate}
class LeaderboardRepository {
  final LeaderboardApi _api = LeaderboardApi();

  // static const _leaderboardLimit = 100;
  // static const _leaderboardCollectionName = 'leaderboard';
  // static const _scoreFieldName = 'score';

  /// Acquires top 10 [LeaderboardEntryData]s.
  Future<List<LeaderboardEntryData>> fetchTop10Leaderboard() async {
    try {
      final response = await _api.leaderboard();
      if (response.statusCode == 200) {
        final data =
            GetLeaderboardDto.fromJson(response.data as Map<String, dynamic>);
        final documents = data.data.map((d) => d.toLeaderboard()).toList();
        return documents;
      }
      return [];
    } on LeaderboardDeserializationException {
      rethrow;
    } on Exception catch (error, stackTrace) {
      throw FetchTop10LeaderboardException(error, stackTrace);
    }
  }

  /// Adds player's score entry to the leaderboard if it is within the top-10
  Future<void> addLeaderboardEntry(
    LeaderboardEntryData entry,
  ) async {
    final leaderboard = await _fetchLeaderboardSortedByScore();
    if (leaderboard.length < 10) {
      await _saveScore(entry);
    } else {
      final tenthPositionScore = leaderboard[9].score;
      if (entry.score > tenthPositionScore) {
        await _saveScore(entry);
      }
    }
  }

  Future<List<LeaderboardEntryData>> _fetchLeaderboardSortedByScore() {
    return fetchTop10Leaderboard();
  }

  Future<void> _saveScore(LeaderboardEntryData entry) {
    try {
      return _api.saveScore(entry);
    } on Exception catch (error, stackTrace) {
      throw AddLeaderboardEntryException(error, stackTrace);
    }
  }

  // ignore: public_member_api_docs
  Future<void> createUser(LeaderboardEntryData entry) {
    try {
      return _api.createUser(entry);
    } on Exception catch (error, stackTrace) {
      throw AddLeaderboardEntryException(error, stackTrace);
    }
  }
}

extension on LeaderboardDto {
  LeaderboardEntryData toLeaderboard() {
    return LeaderboardEntryData(
        phoneNumber: phone, playerInitials: name, score: score);
  }
}
