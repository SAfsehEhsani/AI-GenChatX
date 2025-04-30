// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
      // Optional: Configure Android and iOS options if needed
      // aOptions: AndroidOptions(encryptedSharedPreferences: true),
      // iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  // Keys used to store the API keys in secure storage
  static const String _geminiApiKeyStorageKey = 'geminiApiKey';
  static const String _groqApiKeyStorageKey = 'groqApiKey';

  // --- Gemini API Key ---

  Future<void> saveGeminiApiKey(String apiKey) async {
    try {
      await _storage.write(key: _geminiApiKeyStorageKey, value: apiKey);
      print("Gemini API Key saved securely.");
    } catch (e) {
      print("Error saving Gemini API Key securely: $e");
      // Handle error appropriately (e.g., show a message to the user)
    }
  }

  Future<String?> getGeminiApiKey() async {
    try {
      final key = await _storage.read(key: _geminiApiKeyStorageKey);
      print(
          "Gemini API Key retrieved: ${key != null ? 'Exists' : 'Not Found'}");
      return key;
    } catch (e) {
      print("Error retrieving Gemini API Key securely: $e");
      return null; // Indicate failure
    }
  }

  Future<void> deleteGeminiApiKey() async {
    try {
      await _storage.delete(key: _geminiApiKeyStorageKey);
      print("Gemini API Key deleted from secure storage.");
    } catch (e) {
      print("Error deleting Gemini API Key securely: $e");
    }
  }

  // --- Groq API Key ---

  Future<void> saveGroqApiKey(String apiKey) async {
    try {
      await _storage.write(key: _groqApiKeyStorageKey, value: apiKey);
      print("Groq API Key saved securely.");
    } catch (e) {
      print("Error saving Groq API Key securely: $e");
    }
  }

  Future<String?> getGroqApiKey() async {
    try {
      final key = await _storage.read(key: _groqApiKeyStorageKey);
      print("Groq API Key retrieved: ${key != null ? 'Exists' : 'Not Found'}");
      return key;
    } catch (e) {
      print("Error retrieving Groq API Key securely: $e");
      return null;
    }
  }

  Future<void> deleteGroqApiKey() async {
    try {
      await _storage.delete(key: _groqApiKeyStorageKey);
      print("Groq API Key deleted from secure storage.");
    } catch (e) {
      print("Error deleting Groq API Key securely: $e");
    }
  }

  // --- Clear All (Optional) ---
  Future<void> clearAllSecureData() async {
    try {
      await _storage.deleteAll();
      print("All secure storage data cleared.");
    } catch (e) {
      print("Error clearing all secure storage data: $e");
    }
  }
}
