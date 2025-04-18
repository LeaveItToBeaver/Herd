import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/exception_logging_service.dart';

final exceptionLoggerProvider = Provider<ExceptionLoggerService>((ref) {
  return ExceptionLoggerService();
});
