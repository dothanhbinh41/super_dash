// ignore_for_file: avoid_field_initializers_in_const_classes, avoid_dynamic_calls, omit_local_variable_types, public_member_api_docs, duplicate_ignore

import 'dart:convert';

import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:leaderboard_repository/src/leaderboard_api.dart';
import 'package:leaderboard_repository/src/models/get_leaderboard_dto.dart';
import 'package:leaderboard_repository/src/models/get_user_rank_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        //aaa
        final documents = data.data.map((d) => d.toLeaderboard()).toList();
        return documents;
      }
      return [];
    } on Exception catch (error, stackTrace) {
      return [];
    }
  }

  /// Adds player's score entry to the leaderboard if it is within the top-10
  Future<void> addLeaderboardEntry(int score) async {
    final entry = await currentLeaderboardEntry();
    if (entry == LeaderboardEntryData.empty) {
      return;
    }
    final saveEntry = LeaderboardEntryData(
        phoneNumber: entry!.phoneNumber,
        playerInitials: entry.playerInitials,
        score: score,
        rank: entry.rank);
    final leaderboard = await _fetchLeaderboardSortedByScore();
    if (leaderboard.length < 10) {
      await _saveScore(saveEntry);
    } else {
      final tenthPositionScore = leaderboard[9].score;
      if (saveEntry.score > tenthPositionScore) {
        await _saveScore(entry);
      }
    }
  }

  Future<List<LeaderboardEntryData>> _fetchLeaderboardSortedByScore() {
    return fetchTop10Leaderboard();
  }

  Future<LeaderboardEntryData> getCurrentTop() async {
    final entry = await currentLeaderboardEntry();
    if (entry == null) {
      return LeaderboardEntryData.empty;
    }
    try {
      final response = await _api.getUser(entry.phoneNumber);
      if (response.statusCode == 200) {
        final data =
            GetUserRankDto.fromJson(response.data as Map<String, dynamic>);
        return data.data.toLeaderboard();
      }
    } on Exception catch (error, stackTrace) {}
    return entry;
  }

  Future<void> _saveScore(LeaderboardEntryData entry) async {
    try {
      await _api.saveScore(entry);
    } on Exception catch (error, stackTrace) {}
  }

  // ignore: public_member_api_docs
  Future<void> createUser(LeaderboardEntryData entry) async {
    try {
      await _api.createUser(entry);
      await saveCurrentLeaderboardEntry(entry);
    } on Exception catch (error, stackTrace) {
      print(error.toString());
    }
  }

  Future<LeaderboardEntryData?> currentLeaderboardEntry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('currentLeaderboardEntry') ?? '';
    if (str.isEmpty) {
      return null;
    }
    final json = jsonDecode(str);
    return LeaderboardEntryData.fromJson(json as Map<String, dynamic>);
  }

  Future<void> saveCurrentLeaderboardEntry(LeaderboardEntryData entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(entry.toJson());
    await prefs.setString('currentLeaderboardEntry', json);
  }
}

extension on LeaderboardDto {
  LeaderboardEntryData toLeaderboard() {
    return LeaderboardEntryData(
        phoneNumber: phone, playerInitials: name, score: score, rank: rank);
  }
}
