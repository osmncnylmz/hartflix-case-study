// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthEnvelope _$AuthEnvelopeFromJson(Map<String, dynamic> json) =>
    _AuthEnvelope(
      token: json['token'] as String? ?? '',
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthEnvelopeToJson(_AuthEnvelope instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};
