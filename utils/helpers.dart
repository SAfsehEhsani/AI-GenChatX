// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure 'intl' is in pubspec.yaml

class AppHelpers {
  // Example: Format timestamp for display (more elaborate than just HH:mm)
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (dateToCheck == today) {
      return DateFormat('HH:mm').format(timestamp); // e.g., 14:35
    } else if (dateToCheck == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}'; // e.g., Yesterday 09:15
    } else {
      // Older than yesterday, show date and time
      return DateFormat('MMM d, HH:mm')
          .format(timestamp); // e.g., Jul 25, 10:00
    }
  }

  // Example: Show a simple SnackBar message
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.redAccent
            : Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // You can add more helper functions here as needed, e.g.,
  // - Input validation functions
  // - String manipulation utilities
  // - Consistent logging functions
}
