// ignore_for_file: public_member_api_docs

class GetLeaderboardDto {
  GetLeaderboardDto({
    required this.data,
  });
  factory GetLeaderboardDto.fromJson(Map<String, dynamic> json) =>
      GetLeaderboardDto(
        data: List<LeaderboardDto>.from(
          (json['data'] as Iterable<dynamic>)
              .map((x) => LeaderboardDto.fromJson(x as Map<String, dynamic>)),
        ),
      );
  List<LeaderboardDto> data;

  Map<String, dynamic> toJson() => {
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SaveScoreDto {
  SaveScoreDto({
    required this.error,
    required this.message,
    required this.data,
  });
  factory SaveScoreDto.fromJson(Map<String, dynamic> json) => SaveScoreDto(
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

class LeaderboardDto {
  LeaderboardDto({
    required this.name,
    required this.phone,
    required this.score,
    required this.rank,
  });

  factory LeaderboardDto.fromJson(Map<String, dynamic> json) => LeaderboardDto(
        name: json['name'] as String,
        phone: json['phone'] as String,
        score: json['score'] as int,
        rank: json['rank'] as int,
      );
  String name;
  String phone;
  int score;
  int rank;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'score': score,
        'rank': rank,
      };
}
