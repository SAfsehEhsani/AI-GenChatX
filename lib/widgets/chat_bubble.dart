import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart'; // For colors

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? userBubbleColor : aiBubbleColor;
    final textColor = isUser ? bubbleTextColor : Colors.black87;
    final bubbleAlignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 18),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      alignment: bubbleAlignment,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.75, // Max width 75%
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding:
                EdgeInsets.only(right: isUser ? 4 : 0, left: isUser ? 0 : 4),
            child: Text(
              // Add model name if it's an AI message (and not an error/system message)
              (!isUser &&
                      message.modelUsed != 'error' &&
                      message.modelUsed != 'system' &&
                      message.modelUsed != 'user')
                  ? '${message.modelUsed.toUpperCase()} • ${DateFormat('HH:mm').format(message.timestamp)}'
                  : DateFormat('HH:mm').format(
                      message.timestamp), // Just time for user/error/system
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
