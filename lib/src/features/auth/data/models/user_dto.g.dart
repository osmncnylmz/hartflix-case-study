// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] == null
      ? ''
      : const StringOrIntConverter().fromJson(json['id']),
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': const StringOrIntConverter().toJson(instance.id),
  'name': instance.name,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
};
