import 'package:json_annotation/json_annotation.dart';

class StringOrIntConverter implements JsonConverter<String, Object?> {
  const StringOrIntConverter();
  @override
  String fromJson(Object? json) => json?.toString() ?? '';
  @override
  Object? toJson(String object) => object;
}
