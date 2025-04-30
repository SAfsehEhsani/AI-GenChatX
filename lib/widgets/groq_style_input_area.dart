// lib/widgets/groq_style_input_area.dart
import 'package:flutter/material.dart';

class GroqStyleInputArea extends StatefulWidget {
  final bool isLoading;
  final bool isWebSearchEnabled;
  final ValueChanged<bool> onWebSearchChanged;
  final ValueChanged<String> onSend;

  const GroqStyleInputArea({
    super.key,
    required this.isLoading,
    required this.isWebSearchEnabled,
    required this.onWebSearchChanged,
    required this.onSend,
  });

  @override
  State<GroqStyleInputArea> createState() => _GroqStyleInputAreaState();
}

class _GroqStyleInputAreaState extends State<GroqStyleInputArea> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCanSend);
  }

  void _updateCanSend() {
    if (mounted) {
      // Check if widget is still in the tree
      setState(() {
        _canSend = _controller.text.trim().isNotEmpty;
      });
    }
  }

  void _sendMessage() {
    if (_canSend && !widget.isLoading) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      // Keep focus on the text field after sending
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCanSend);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      // Provides elevation and background
      elevation: 8.0, // Shadow for separation
      color: theme.cardColor, // Background color for the input area container
      child: Padding(
        // Padding around the entire input area content
        padding: const EdgeInsets.fromLTRB(
            12.0, 12.0, 12.0, 8.0), // Less padding at bottom
        child: SafeArea(
          // Ensures content avoids system intrusions (like keyboard, notches) at the bottom
          top: false, // Don't apply safe area padding to the top
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Column takes minimum vertical space needed
            children: [
              // Row containing the text field and send button
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .end, // Align button bottom with text field bottom
                children: [
                  // Flexible text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction
                          .send, // Suggest 'Send' action on keyboard
                      onSubmitted: widget.isLoading
                          ? null
                          : (_) =>
                              _sendMessage(), // Allow sending via keyboard action
                      minLines: 1,
                      maxLines: 5, // Allow input to expand up to 5 lines
                      enabled: !widget.isLoading, // Disable field when loading
                      decoration: InputDecoration(
                          hintText: 'Ask anything...', // Placeholder text
                          filled: true, // Use a fill color
                          fillColor: theme
                              .scaffoldBackgroundColor, // Background color inside the field
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0), // Padding inside the field
                          // Border definition
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(25.0), // Rounded corners
                            borderSide: BorderSide
                                .none, // No visible border when unfocused
                          ),
                          // Border when the field is focused
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 1.5), // Highlight border when focused
                          )),
                      style: const TextStyle(
                          fontSize: 16), // Text style inside the field
                    ),
                  ),
                  const SizedBox(
                      width: 8.0), // Spacing between text field and button
                  // Send button section
                  SizedBox(
                    height: 48, // Fixed height to roughly match text field
                    child: ElevatedButton(
                      // Disable button if not able to send or if loading
                      onPressed:
                          (_canSend && !widget.isLoading) ? _sendMessage : null,
                      style: ElevatedButton.styleFrom(
                        // Button shape
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              25.0), // Match text field rounding
                        ),
                        // Internal padding of the button
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        // Colors
                        backgroundColor:
                            theme.colorScheme.primary, // Button background
                        foregroundColor:
                            theme.colorScheme.onPrimary, // Icon/Text color
                        // Remove splash effect when disabled
                        splashFactory: (_canSend && !widget.isLoading)
                            ? InkSplash.splashFactory
                            : NoSplash.splashFactory,
                      ).copyWith(
                        // More explicit control over overlay color (splash/highlight)
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled))
                              return Colors.transparent;
                            if (states.contains(MaterialState.pressed))
                              return theme.colorScheme.onPrimary
                                  .withOpacity(0.12);
                            if (states.contains(MaterialState.hovered))
                              return theme.colorScheme.onPrimary
                                  .withOpacity(0.08);
                            return null; // Defer to default overlay color otherwise
                          },
                        ),
                      ),
                      // Content of the button: Loading indicator or Send Icon
                      child: widget.isLoading
                          ? const SizedBox(
                              // Loading indicator
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.white, // Indicator color
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded,
                              size: 24), // Send icon
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 8.0), // Space between input row and toggle row
              // Row containing the Web Search toggle
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the toggle elements
                children: [
                  Text(
                    // Label for the switch
                    'Web Search',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(width: 4), // Space between label and switch
                  Switch(
                    // The toggle switch
                    value: widget
                        .isWebSearchEnabled, // Controlled by provider state
                    // Disable switch interaction when app is loading a response
                    onChanged:
                        widget.isLoading ? null : widget.onWebSearchChanged,
                    activeColor:
                        theme.colorScheme.primary, // Color when switch is ON
                    materialTapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // Reduce padding around the switch
                    // visualDensity was here - IT IS REMOVED
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
