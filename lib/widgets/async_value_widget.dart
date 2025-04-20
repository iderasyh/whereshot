import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whereshot/theme/app_theme.dart';

/// A reusable widget to handle the common states of an [AsyncValue].
///
/// It simplifies displaying data, loading, and error states from Riverpod providers.
class AsyncValueWidget<T> extends StatelessWidget {
  /// The [AsyncValue] to display.
  final AsyncValue<T> value;

  /// The builder function to call when the [AsyncValue] has data.
  final Widget Function(T data) data;

  /// An optional widget to display while the [AsyncValue] is loading.
  ///
  /// Defaults to a centered, platform-adaptive activity indicator.
  final Widget? loading;

  /// An optional builder function to call when the [AsyncValue] has an error.
  ///
  /// Defaults to a simple centered error message.
  final Widget Function(Object error, StackTrace stackTrace)? error;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ??
          Center(
            child: AppTheme.adaptiveWidget(
              context: context,
              material: const CircularProgressIndicator(),
              cupertino: const CupertinoActivityIndicator(),
            ),
          ),
      error: (e, st) =>
          error?.call(e, st) ??
          Center(
            child: Text(
              'Error: ${e.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
    );
  }
} 