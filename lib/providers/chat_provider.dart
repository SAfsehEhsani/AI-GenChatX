// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/database_service.dart'; // Import the service

enum AiModel { gemini, groq }

class ChatProvider with ChangeNotifier {
  // === FIX: Access the Singleton instance ===
  // Instead of creating a new instance, get the static instance from DatabaseService
  final DatabaseService _dbService = DatabaseService.instance;
  // =========================================

  // ApiService can still be instantiated directly if not using injection
  final ApiService _apiService = ApiService();

  // State variables
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  AiModel _selectedModel = AiModel.gemini;

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AiModel get selectedModel => _selectedModel;

  // Constructor - Initializes by calling _initialize
  ChatProvider() {
    _initialize();
  }

  // Unified initialization logic
  Future<void> _initialize() async {
    // If ApiService needs async initialization (e.g., for secure keys)
    // await _apiService.initialize(); // Uncomment if needed
    await _loadHistory(); // Load history using the db instance
  }

  Future<void> _loadHistory() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Use the singleton instance '_dbService'
      _messages = await _dbService.loadChatHistory();
      if (_messages.isEmpty) {
        _messages.add(ChatMessage(
          text: "Hello! How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
          modelUsed: _selectedModel.name,
        ));
      }
    } catch (e) {
      print("Error loading chat history: $e");
      _errorMessage = "Failed to load chat history: $e";
      _messages = [
        ChatMessage(
          text: "Error loading history. How can I help?",
          isUser: false,
          timestamp: DateTime.now(),
          modelUsed: _selectedModel.name,
        )
      ];
    } finally {
      await Future.delayed(const Duration(milliseconds: 50));
      _setLoading(false);
    }
  }

  void switchModel(AiModel model) {
    if (_selectedModel != model) {
      _selectedModel = model;
      print("Switched to model: ${_selectedModel.name}");
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      modelUsed: 'user',
    );

    _messages.add(userMessage);
    _errorMessage = null;
    _setLoading(true);
    notifyListeners();

    try {
      // Use the singleton instance '_dbService'
      await _dbService.saveMessage(userMessage);
    } catch (e) {
      print("Error saving user message: $e");
      _errorMessage = "Error saving your message.";
      _setLoading(false);
      notifyListeners();
      return;
    }

    // Get AI Response
    String? responseText;
    String modelUsed = _selectedModel.name;
    ChatMessage? aiMessage;

    try {
      List<ChatMessage> apiHistory = _messages
          .where((m) => m.modelUsed != 'system' && m.modelUsed != 'error')
          .toList();

      if (_selectedModel == AiModel.gemini) {
        responseText =
            await _apiService.sendMessageToGemini(userMessage.text, apiHistory);
      } else {
        responseText =
            await _apiService.sendMessageToGroq(userMessage.text, apiHistory);
      }

      if (responseText == null ||
          responseText.startsWith("Error") ||
          responseText.startsWith("Groq API Error") ||
          responseText.contains("API Key not configured")) {
        _errorMessage = responseText ?? "Received null response from AI.";
        modelUsed = 'error';
        responseText = responseText ?? "Sorry, I couldn't get a response.";
      } else {
        _errorMessage = null;
      }
    } catch (e) {
      print("Error getting AI response in ChatProvider: $e");
      responseText = "Sorry, an unexpected error occurred.";
      _errorMessage = responseText;
      modelUsed = 'error';
    } finally {
      aiMessage = ChatMessage(
        text: responseText ?? "No response generated.",
        isUser: false,
        timestamp: DateTime.now(),
        modelUsed: modelUsed,
      );
      _messages.add(aiMessage);

      try {
        // Use the singleton instance '_dbService'
        await _dbService.saveMessage(aiMessage);
      } catch (e) {
        print("Error saving AI message: $e");
        _errorMessage = "Error saving AI response to history.";
      }

      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Use the singleton instance '_dbService'
      await _dbService.clearChatHistory();
      _messages = [
        ChatMessage(
          text: "Chat cleared. How can I help you?",
          isUser: false,
          timestamp: DateTime.now(),
          modelUsed: _selectedModel.name,
        )
      ];
    } catch (e) {
      print("Error clearing chat history: $e");
      _errorMessage = "Failed to clear chat history.";
      _messages = [
        ChatMessage(
          text: "Error clearing chat. Ask me anything.",
          isUser: false,
          timestamp: DateTime.now(),
          modelUsed: _selectedModel.name,
        )
      ];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ChangeNotifier.debugAssertNotDisposed(this)) {
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    print("ChatProvider disposed");
    super.dispose();
  }
}
