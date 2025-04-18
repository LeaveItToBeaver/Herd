import 'package:flutter/cupertino.dart';

Map<String, dynamic> safeMapConversion(Object? obj) {
  if (obj == null) {
    return {};
  }

  if (obj is Map<String, dynamic>) {
    return obj;
  }

  if (obj is Map) {
    // Convert Map to Map<String, dynamic>
    return Map<String, dynamic>.from(obj.map(
      (key, value) => MapEntry(key.toString(), value),
    ));
  }

  debugPrint(
      'Warning: Failed to convert object to Map<String, dynamic>: ${obj.runtimeType}');
  return {};
}
