import 'dart:convert';
import 'package:ai_baatchit/models/chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart'; // !! Import keys (Dev only!)

class ApiService {
  // --- Gemini ---
  GenerativeModel? _geminiModel;

  ApiService() {
    // !! In production, fetch key securely before initializing
    if (geminiApiKey.isNotEmpty && geminiApiKey != "YOUR_GEMINI_API_KEY") {
      _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash-latest', apiKey: geminiApiKey);
      // Or use 'gemini-pro' if needed
    } else {
      print("WARNING: Gemini API Key not set in constants.dart");
    }
  }

  Future<String?> sendMessageToGemini(
      String message, List<ChatMessage> history) async {
    if (_geminiModel == null) return "Gemini API Key not configured.";

    try {
      final chat = _geminiModel!.startChat(
          history: history
              .map((msg) =>
                  Content(msg.isUser ? 'user' : 'model', [TextPart(msg.text)]))
              .toList() // Convert history to Gemini's format
          );
      final response = await chat.sendMessage(Content.text(message));
      print("Gemini Raw Response: ${response.text}"); // Debugging
      return response.text;
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "Error communicating with Gemini: ${e.toString()}";
    }
  }

  // --- Groq ---
  final String _groqApiUrl = "https://api.groq.com/openai/v1/chat/completions";
  // You might want to let the user choose the model via UI later
  final String _groqModel = "llama3-8b-8192"; // Or "mixtral-8x7b-32768" etc.

  Future<String?> sendMessageToGroq(
      String message, List<ChatMessage> history) async {
    if (groqApiKey.isEmpty || groqApiKey == "YOUR_GROQ_API_KEY") {
      return "Groq API Key not configured.";
    }

    // Construct history for Groq (OpenAI format)
    List<Map<String, String>> messages = history.map((msg) {
      return {
        "role": msg.isUser ? "user" : "assistant",
        "content": msg.text,
      };
    }).toList();
    // Add the current user message
    messages.add({"role": "user", "content": message});

    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "messages": messages,
          "model": _groqModel,
        }),
      );

      print("Groq Status Code: ${response.statusCode}"); // Debugging
      print("Groq Response Body: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content']?.trim();
        } else {
          return "Groq returned an empty response structure.";
        }
      } else {
        // Attempt to parse error message from Groq response
        String errorMsg = "Groq API Error: ${response.statusCode}";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null &&
              errorData['error']['message'] != null) {
            errorMsg += " - ${errorData['error']['message']}";
          } else {
            errorMsg += " - ${response.body}"; // Fallback to raw body
          }
        } catch (_) {
          errorMsg += " - ${response.body}"; // Fallback if JSON parsing fails
        }
        print(errorMsg); // Log the detailed error
        return errorMsg; // Return error message to display
      }
    } catch (e) {
      print("Error calling Groq API: $e");
      return "Error communicating with Groq: ${e.toString()}";
    }
  }
}
