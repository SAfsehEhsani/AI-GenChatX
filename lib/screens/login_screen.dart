import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import chat screen for navigation
import '../utils/constants.dart'; // For theme/colors
//import '../widgets/custom_button.dart'; // Assuming you create a custom button

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() {
    // Simulate login process (replace with real auth later if needed)
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Check if the widget is still in the tree
          setState(() => _isLoading = false);
          // Navigate to Chat Screen on successful "login"
          Navigator.pushReplacement(
            // Use pushReplacement so user can't go back to login
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Optional: Add a subtle background image or gradient
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/login_background.png"), // Add your image
        //     fit: BoxFit.cover,
        //     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        //   ),
        // ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.8),
              accentColor.withOpacity(0.6)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Allows scrolling on smaller screens
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // App Logo or Title
                  Icon(
                    Icons.chat_bubble_rounded,
                    size: size.width * 0.25, // Responsive size
                    color: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'AI Chat Companion',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Login to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field (Placeholder - Adapt if using real auth)
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email (e.g., user@example.com)',
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    validator: (value) {
                      // Simple validation
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field (Placeholder)
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password (any password works)',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    validator: (value) {
                      // Simple validation
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Login Button
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : CustomButton(
                          // Use your custom button or ElevatedButton
                          text: 'Login',
                          onPressed: _login,
                          backgroundColor: Colors.white, // Contrasting button
                          textColor: primaryColor, // Text color matching theme
                        ),

                  // Optional: Add Forgot Password or Sign Up links
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {/* TODO: Implement forgot password */},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example Custom Button Widget (lib/widgets/custom_button.dart)
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
      ),
      child: Text(text),
    );
  }
}
