import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whereshot/theme/app_theme.dart'; // Assuming AppTheme for adaptive widgets

/// Helper function to show a platform-adaptive alert dialog for exceptions.
Future<void> showExceptionAlertDialog({
  required BuildContext context,
  required String title,
  required dynamic exception,
}) =>
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(_message(exception)),
        actions: <Widget>[
          AppTheme.adaptiveWidget(
            context: context, // Use adaptive button based on theme
            material: TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            cupertino: TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );

String _message(dynamic exception) {
  if (exception is Exception) {
    // Try to extract a more user-friendly message if possible
    // For now, just use toString()
    return exception.toString().replaceFirst('Exception: ', '');
  }
  return exception.toString();
}

/// A helper [AsyncValue] extension to show an alert dialog on error
extension AsyncValueUI on AsyncValue {
  /// Show an alert dialog if the current [AsyncValue] has an error and the
  /// state is not loading.
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      showExceptionAlertDialog(
        context: context,
        title: 'Error',
        exception: error ?? 'Unknown error', // Pass the actual error
      );
    }
  }

  // Removed showCustomAlertDialogOnError as it's similar to the above
} 