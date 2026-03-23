import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// 🔥 PUT YOUR REAL OPENROUTER API KEY HERE
  static const String apiKey = "PASTE_YOUR_API_KEY";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://yourapp.com", // can be anything
          "X-Title": "AI Assistant"
        },
        body: jsonEncode({
          /// ✅ UPDATED MODEL (IMPORTANT)
          "model": "openai/gpt-4o-mini",

          "messages": [
            {
              "role": "system",
              "content": "You are a helpful AI assistant."
            },
            {
              "role": "user",
              "content": message
            }
          ],
        }),
      );

      /// 🔍 DEBUG PRINT (VERY IMPORTANT)
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["choices"][0]["message"]["content"] ?? "No response";
      } else if (response.statusCode == 401) {
        return "❌ Unauthorized (Check API Key)";
      } else if (response.statusCode == 429) {
        return "⚠️ Too many requests. Try later.";
      } else {
        return "❌ Error: ${response.statusCode}\n${response.body}";
      }
    } catch (e) {
      return "❌ Connection error: $e";
    }
  }
}