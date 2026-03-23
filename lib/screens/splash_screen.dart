import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    /// 🔥 DELAY THEN NAVIGATE
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// 🌌 GRADIENT BACKGROUND
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// 🔥 LOGO
              Image.asset(
                "assets/images/logo.png",
                height: 100,
              ),

              const SizedBox(height: 20),

              /// 🧠 APP NAME
              const Text(
                "AI Assistant",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              /// ✨ SHORT DESCRIPTION
              const Text(
                "Your smart companion for everything.\nAsk, learn, and explore instantly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔄 LOADING INDICATOR
              const CircularProgressIndicator(
                color: Color(0xFF22D3EE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}