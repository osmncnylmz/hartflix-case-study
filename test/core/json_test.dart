import 'package:flutter_test/flutter_test.dart';
import 'package:sinflix/src/core/json/string_or_int_converter.dart';
import 'package:sinflix/src/core/network/json_utils.dart';

void main() {
  group('unwrapData', () {
    // The case API wraps every successful payload as
    // `{"response": {...}, "data": {...}}`.
    test('parses the inner "data" object when the envelope is present', () {
      final body = <String, dynamic>{
        'response': {'code': 200},
        'data': {'name': 'Ada'},
      };

      final name = unwrapData<String>(body, (json) => json['name'] as String);

      expect(name, 'Ada');
    });

    test('falls back to the body itself when there is no envelope', () {
      final body = <String, dynamic>{'name': 'Ada'};

      final name = unwrapData<String>(body, (json) => json['name'] as String);

      expect(name, 'Ada');
    });

    test('passes an empty map to the parser for a non-map body', () {
      final parsed = unwrapData<int>('not a map', (json) => json.length);

      expect(parsed, 0);
    });

    test('ignores a "data" key that is not a map', () {
      final body = <String, dynamic>{
        'data': ['a', 'b'],
        'name': 'Ada',
      };

      final name = unwrapData<String>(body, (json) => json['name'] as String);

      expect(name, 'Ada');
    });
  });

  group('StringOrIntConverter', () {
    // The API returns user ids as either a string or a number depending on
    // the endpoint, so the converter normalises both to String.
    const converter = StringOrIntConverter();

    test('keeps a string unchanged', () {
      expect(converter.fromJson('abc123'), 'abc123');
    });

    test('stringifies an int', () {
      expect(converter.fromJson(42), '42');
    });

    test('maps null to an empty string', () {
      expect(converter.fromJson(null), '');
    });

    test('round-trips back out as the same string', () {
      expect(converter.toJson('abc123'), 'abc123');
    });
  });
}
