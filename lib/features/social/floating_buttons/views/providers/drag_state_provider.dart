import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drag_state_provider.g.dart';

@riverpod
class IsDragging extends _$IsDragging {
  @override
  bool build() => false;
}
