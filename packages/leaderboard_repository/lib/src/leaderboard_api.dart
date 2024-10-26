// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

class LeaderboardApi {
  static const baseUrl = 'https://api2.edutalk.edu.vn';
  static final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 13),
  );
  final dio = Dio(options);

  Future<Response<dynamic>> createUser(LeaderboardEntryData data) {
    return dio.post('/super-dash/cambridgeGameUser',
        data: {'phone': data.phoneNumber, 'name': data.playerInitials});
  }

  Future<Response<dynamic>> getUser(String phone) {
    return dio.get(
      '/super-dash/cambridgeGameUser/rankingByPhone',
      queryParameters: {'phone': phone},
    );
  }

  Future<Response<dynamic>> leaderboard() {
    return dio.get('/super-dash/cambridgeGameUser/score');
  }

  Future<Response<dynamic>> saveScore(LeaderboardEntryData data) {
    return dio.post(
      '/super-dash/cambridgeGameUser/score',
      data: {'phone': data.phoneNumber, 'score': data.score},
    );
  }

  Future<Response<dynamic>> getFinishTime() {
    return dio.get('/super-dash/cambridgeGameUser/end-time');
  }
}
