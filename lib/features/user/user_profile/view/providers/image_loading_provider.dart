import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_loading_provider.g.dart';

@riverpod
class ImageLoading extends _$ImageLoading {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}
