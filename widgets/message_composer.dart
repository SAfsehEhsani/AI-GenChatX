import 'package:flutter/material.dart';
//import '../utils/constants.dart'; // For colors

class MessageComposer extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const MessageComposer({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canSend = _controller.text.trim().isNotEmpty;
      });
    });
  }

  void _sendMessage() {
    if (_canSend && !widget.isLoading) {
      widget.onSend(_controller.text);
      _controller.clear(); // Clear text field after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Use scaffold background
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        // Ensure it avoids notches etc. at bottom
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.isLoading ? null : (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  // Using theme's input decoration here
                ),
                minLines: 1,
                maxLines: 5, // Allow multi-line input
                enabled: !widget.isLoading, // Disable input when loading
              ),
            ),
            const SizedBox(width: 8.0),
            widget.isLoading
                ? const Padding(
                    padding:
                        EdgeInsets.all(8.0), // Padding for size consistency
                    child: SizedBox(
                      width: 24, // Match icon size approx
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: _canSend
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    onPressed: _canSend
                        ? _sendMessage
                        : null, // Enable only if text exists
                    tooltip: 'Send message',
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
