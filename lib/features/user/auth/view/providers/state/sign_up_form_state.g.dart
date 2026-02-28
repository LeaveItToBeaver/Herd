// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_form_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpForm)
const signUpFormProvider = SignUpFormProvider._();

final class SignUpFormProvider
    extends $NotifierProvider<SignUpForm, SignUpFormState> {
  const SignUpFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signUpFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signUpFormHash();

  @$internal
  @override
  SignUpForm create() => SignUpForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpFormState>(value),
    );
  }
}

String _$signUpFormHash() => r'74ed6f751950aaf1d4bdbebd12225c6336c8519d';

abstract class _$SignUpForm extends $Notifier<SignUpFormState> {
  SignUpFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SignUpFormState, SignUpFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SignUpFormState, SignUpFormState>,
        SignUpFormState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
