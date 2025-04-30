import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_composer.dart';
//import '../utils/constants.dart'; // For theme colors etc.

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen to provider changes to scroll down
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.addListener(_scrollToBottom); // Listen for changes
      _scrollToBottom(jump: true); // Initial scroll
    });
  }

  void _scrollToBottom({bool jump = false}) {
    // Only scroll if the scroll controller is attached to a view
    if (_scrollController.hasClients) {
      // Give it a tiny delay to allow the layout to build after adding a message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (jump) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up listener and controller
    // Checking if mounted prevents errors if dispose is called before provider listener is added
    if (mounted) {
      Provider.of<ChatProvider>(context, listen: false)
          .removeListener(_scrollToBottom);
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for parts that need rebuilding on provider change
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(builder: (context, provider, child) {
          return Text(
              "BaatChit AI Chat (${provider.selectedModel.name.toUpperCase()})");
        }),
        actions: [
          Consumer<ChatProvider>(builder: (context, provider, child) {
            return PopupMenuButton<AiModel>(
              icon: const Icon(Icons.model_training),
              tooltip: "Switch AI Model",
              onSelected: (AiModel result) {
                provider.switchModel(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<AiModel>>[
                const PopupMenuItem<AiModel>(
                  value: AiModel.gemini,
                  child: Text('Gemini'),
                ),
                const PopupMenuItem<AiModel>(
                  value: AiModel.groq,
                  child: Text('Groq (Llama3)'),
                ),
              ],
            );
          }),
          // Clear Chat Action
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Clear Chat History",
            onPressed: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Chat?'),
                    content: const Text(
                        'This will permanently delete all messages in this chat.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false
                        },
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Clear'),
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                      ),
                    ],
                  );
                },
              );

              // If confirmed, clear the chat
              if (confirm == true) {
                // Use context.read for one-off actions inside callbacks
                context.read<ChatProvider>().clearChat();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display error message if any
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (provider.errorMessage != null &&
                      provider.errorMessage!.startsWith("Error") ||
                  provider.errorMessage != null &&
                      provider.errorMessage!.startsWith("Groq API Error")) {
                return Container(
                  color: Colors.redAccent.withOpacity(0.8),
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return const SizedBox.shrink(); // No error, show nothing
              }
            },
          ),
          // Chat Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.messages.length <= 1) {
                  // Show loading indicator only when initially loading history
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Text("Send a message to start chatting!"),
                  );
                }
                // Use ListView.builder for performance with long lists
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                      bottom: 10.0, top: 10.0), // Padding top/bottom
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),
          // Message Input Area
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              return MessageComposer(
                // Use context.read for one-off actions inside callbacks
                onSend: (text) =>
                    context.read<ChatProvider>().sendMessage(text),
                isLoading: provider
                    .isLoading, // Pass loading state to disable input/show indicator
              );
            },
          ),
        ],
      ),
    );
  }
}
