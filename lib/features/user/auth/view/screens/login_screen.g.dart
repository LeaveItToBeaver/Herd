// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginForm)
const loginFormProvider = LoginFormProvider._();

final class LoginFormProvider
    extends $NotifierProvider<LoginForm, LoginFormState> {
  const LoginFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loginFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loginFormHash();

  @$internal
  @override
  LoginForm create() => LoginForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormState>(value),
    );
  }
}

String _$loginFormHash() => r'e94ff15a37b3a61365e92b8742937d7c38a74baa';

abstract class _$LoginForm extends $Notifier<LoginFormState> {
  LoginFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LoginFormState, LoginFormState>,
        LoginFormState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
