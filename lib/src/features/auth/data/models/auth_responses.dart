import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_dto.dart';

part 'auth_responses.freezed.dart';
part 'auth_responses.g.dart';

@freezed
class AuthEnvelope with _$AuthEnvelope {
  const factory AuthEnvelope({
    @Default('') String token,
    required UserDto user,
  }) = _AuthEnvelope;

  factory AuthEnvelope.fromJson(Map<String, dynamic> json) =>
      _$AuthEnvelopeFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
