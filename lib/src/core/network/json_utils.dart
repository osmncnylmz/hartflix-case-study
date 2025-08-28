T unwrapData<T>(dynamic body, T Function(Map<String, dynamic>) parser) {
  final map = (body is Map<String, dynamic>) ? body : <String, dynamic>{};
  final raw = (map['data'] is Map<String, dynamic>)
      ? map['data'] as Map<String, dynamic>
      : map;
  return parser(raw);
}
