import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final TextEditingController emailController =
      TextEditingController();

  bool isLoading = false;

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage("Please enter email");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(email)) {
      showMessage("Enter valid email");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      showMessage("Reset link sent 📩");

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Error");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF343541),

      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: const Color(0xFF202123),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            const Text(
              "Enter your email to reset password",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : resetPassword,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}