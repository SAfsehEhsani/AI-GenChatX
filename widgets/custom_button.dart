// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Can be null to disable the button
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final bool isLoading; // Added for loading state

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50.0, // Default height for consistency
    this.elevation,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.isLoading = false, // Default to not loading
  });

  @override
  Widget build(BuildContext context) {
    // Get the default style from the theme
    final ButtonStyle? defaultStyle =
        Theme.of(context).elevatedButtonTheme.style;

    // Create the custom style, merging defaults with provided overrides
    final ButtonStyle customStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ??
          defaultStyle?.backgroundColor
              ?.resolve({}), // Use provided or theme default
      foregroundColor: textColor ??
          defaultStyle?.foregroundColor
              ?.resolve({}), // Use provided or theme default for text/icon
      elevation: elevation ?? defaultStyle?.elevation?.resolve({}),
      padding: padding ?? defaultStyle?.padding?.resolve({}),
      minimumSize: (width != null || height != null)
          ? Size(width ?? 0, height ?? 0) // Apply width/height if provided
          : defaultStyle?.minimumSize?.resolve({}),
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : defaultStyle?.shape
              ?.resolve({}), // Use provided or theme default shape
      textStyle: textStyle ?? defaultStyle?.textStyle?.resolve({}),
    );

    return SizedBox(
      width:
          width, // Apply width to SizedBox if provided, otherwise button takes intrinsic width or minimumSize
      height: height,
      child: ElevatedButton(
        style: customStyle,
        // Disable onPressed if null OR if isLoading is true
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: (height ?? 50) *
                    0.5, // Make indicator size relative to button height
                height: (height ?? 50) * 0.5,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  // Use the button's foreground color for the indicator if possible
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ??
                        Theme.of(context)
                            .colorScheme
                            .onPrimary, // Sensible fallback
                  ),
                ),
              )
            : Text(text),
      ),
    );
  }
}
