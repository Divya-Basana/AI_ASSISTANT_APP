import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// 🔥 VALIDATION
  String? validate() {
    if (emailController.text.isEmpty) {
      return "Email is required";
    }
    if (!emailController.text.contains("@")) {
      return "Enter valid email";
    }
    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  /// 🔥 EMAIL LOGIN / SIGNUP
  Future<void> authenticate() async {
    final error = validate();

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      print("✅ Email login success");

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }

    setState(() => isLoading = false);
  }

  /// 🔥 GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      print("✅ Google Sign-In Success");

    } catch (e) {
      print("❌ Google Sign-In Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🌌 BACKGROUND GRADIENT
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(24),

              /// 💎 CARD
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  )
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔥 LOGO + TITLE
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/logo.png",
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isLogin
                            ? "Welcome Back 👋"
                            : "Create Account 🚀",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// EMAIL
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon:
                          const Icon(Icons.email, color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF020617),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon:
                          const Icon(Icons.lock, color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF020617),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  /// FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔵 LOGIN / SIGNUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              await authenticate();
                            },
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF22D3EE),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            isLogin ? "Sign In" : "Sign Up",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🔘 GOOGLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              await signInWithGoogle();
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.g_mobiledata,
                          color: Color(0xFF22D3EE), size: 28),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// SWITCH LOGIN/SIGNUP
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Sign In",
                      style:
                          const TextStyle(color: Colors.white54),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// LOADING
                  if (isLoading)
                    const CircularProgressIndicator(
                      color: Color(0xFF22D3EE),
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