// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showWelcomeMessageHash() =>
    r'e50490a7b0df5a38f6fdfc705e5baf6d27ccca05';

/// Provider to control whether the initial welcome message should be shown.
/// This is set to true after the first anonymous sign-in and reset after display.
///
/// Copied from [ShowWelcomeMessage].
@ProviderFor(ShowWelcomeMessage)
final showWelcomeMessageProvider =
    NotifierProvider<ShowWelcomeMessage, bool>.internal(
      ShowWelcomeMessage.new,
      name: r'showWelcomeMessageProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$showWelcomeMessageHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowWelcomeMessage = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
