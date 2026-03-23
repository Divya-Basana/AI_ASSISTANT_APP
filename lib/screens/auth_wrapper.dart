import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        print("Auth state: ${snapshot.data}"); // 🔥 DEBUG

        /// 🔄 LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// ❌ NOT LOGGED IN
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        /// ✅ LOGGED IN
        return HomeScreen();
      },
    );
  }
}