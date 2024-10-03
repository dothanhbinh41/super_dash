// ignore_for_file: public_member_api_docs

class GetUserRankDto {
  GetUserRankDto({
    required this.error,
    required this.message,
    required this.data,
  });
  factory GetUserRankDto.fromJson(Map<String, dynamic> json) => GetUserRankDto(
        error: json['error'] as bool,
        message: json['message'],
        data: DataUserRankDto.fromJson(json['data'] as Map<String, dynamic>),
      );
  bool error;
  dynamic message;
  DataUserRankDto data;

  Map<String, dynamic> toJson() => {
        'error': error,
        'message': message,
        'data': data.toJson(),
      };
}

class DataUserRankDto {
  DataUserRankDto({
    required this.rank,
  });
  factory DataUserRankDto.fromJson(Map<String, dynamic> json) =>
      DataUserRankDto(
        rank: json['rank'] as int,
      );
  int rank;

  Map<String, dynamic> toJson() => {
        'rank': rank,
      };
}
