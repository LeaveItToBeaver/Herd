import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavLock extends _$NavLock {
  @override
  bool build() => false;
}
