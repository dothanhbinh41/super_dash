// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:leaderboard_repository/src/models/create_user_dto.dart';
import 'package:leaderboard_repository/src/models/get_leaderboard_dto.dart';
import 'package:leaderboard_repository/src/models/get_user_rank_dto.dart';

class LeaderboardApi {
  static const baseUrl = 'https://beta-api.edutalk.edu.vn';
  static final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  );
  final dio = Dio(options);

  Future<Response<CreateUserDto>> createUser(LeaderboardEntryData data) {
    return dio.post<CreateUserDto>('/super-dash/cambridgeGameUser',
        data: {'phone': data.phoneNumber, 'name': data.playerInitials});
  }

  Future<Response<GetUserRankDto>> getUser(String phone) {
    return dio.post<GetUserRankDto>(
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
      data: {
        'phone':
            data.phoneNumber.isEmpty ? data.playerInitials : data.phoneNumber,
        'score': data.score
      },
    );
  }
}
