import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/chat_provider.dart';

import 'screens/splash_screen.dart'; // 🔥 NEW IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // 🔥 IMPORTANT

  final chatProvider = ChatProvider();

  runApp(MyApp(chatProvider));
}

class MyApp extends StatelessWidget {
  final ChatProvider chatProvider;

  const MyApp(this.chatProvider);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: chatProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        /// 🔥 CUSTOM AI THEME
        theme: ThemeData(
          brightness: Brightness.dark,

          /// 🎨 COLORS
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          primaryColor: const Color(0xFF2563EB),

          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2563EB),
            secondary: Color(0xFF22D3EE),
            background: Color(0xFF0F172A),
          ),

          /// 📝 TEXT THEME
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
          ),

          /// 🔘 BUTTON THEME
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          /// 🧾 INPUT FIELD THEME
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),

          /// 📱 APP BAR THEME
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF020617),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),

          /// 💬 SNACKBAR
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF1E293B),
            contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),

        /// 🔥 START WITH SPLASH SCREEN
        home: SplashScreen(),
      ),
    );
  }
}