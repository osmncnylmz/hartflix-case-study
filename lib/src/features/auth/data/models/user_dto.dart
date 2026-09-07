import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/json/string_or_int_converter.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    @StringOrIntConverter() @Default('') String id,
    @Default('') String name,
    @Default('') String email,
    String? photoUrl,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
