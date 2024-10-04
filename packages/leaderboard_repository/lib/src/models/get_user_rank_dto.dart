// ignore_for_file: public_member_api_docs

import 'package:leaderboard_repository/src/models/get_leaderboard_dto.dart';

class GetUserRankDto {
  GetUserRankDto({
    required this.error,
    required this.message,
    required this.data,
  });
  factory GetUserRankDto.fromJson(Map<String, dynamic> json) => GetUserRankDto(
        error: json['error'] as bool,
        message: json['message'],
        data: LeaderboardDto.fromJson(json['data'] as Map<String, dynamic>),
      );
  bool error;
  dynamic message;
  LeaderboardDto data;

  Map<String, dynamic> toJson() => {
        'error': error,
        'message': message,
        'data': data.toJson(),
      };
}
