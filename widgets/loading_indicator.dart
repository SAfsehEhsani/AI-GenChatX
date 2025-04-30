// lib/widgets/loading_indicator.dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? text; // Optional text below the indicator
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.text,
    this.size = 30.0,
    this.strokeWidth = 3.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Take only needed vertical space
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ??
                    Theme.of(context)
                        .colorScheme
                        .primary, // Use theme color if null
              ),
            ),
          ),
          if (text != null && text!.isNotEmpty) ...[
            // Conditionally add SizedBox and Text
            const SizedBox(height: 12),
            Text(
              text!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}
