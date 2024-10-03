// To parse this JSON data, do
//
//     final createUserDto = createUserDtoFromJson(jsonString);

// ignore_for_file: public_member_api_docs

class CreateUserDto {
  CreateUserDto({
    required this.error,
    required this.message,
    required this.data,
  });
  factory CreateUserDto.fromJson(Map<String, dynamic> json) => CreateUserDto(
        error: json['error'] as bool,
        message: json['message'],
        data: DataUserDto.fromJson(json['data'] as Map<String, dynamic>),
      );
  bool error;
  dynamic message;
  DataUserDto data;

  Map<String, dynamic> toJson() => {
        'error': error,
        'message': message,
        'data': data.toJson(),
      };
}

class DataUserDto {
  DataUserDto({required this.name, required this.phone});
  factory DataUserDto.fromJson(Map<String, dynamic> json) =>
      DataUserDto(name: json['name'] as String, phone: json['phone'] as String);
  String name;
  String phone;

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
}
