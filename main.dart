import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart'; // Start with login screen
// import 'screens/chat_screen.dart'; // Or start directly with chat for testing
import 'utils/constants.dart'; // For buildTheme

void main() {
  // Ensure Flutter bindings are initialized (needed for async calls before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Wrap the entire app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => ChatProvider(), // Create your provider instance
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: buildTheme(), // Apply the custom theme
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: const LoginScreen(), // Start with Login Screen
      // home: const ChatScreen(), // Or uncomment this to skip login during dev
    );
  }
}
