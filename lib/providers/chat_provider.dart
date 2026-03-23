import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  String? _currentChatId;
  Chat? _tempChat;

  bool isLoading = false;

  /// 🔥 RENAME STATE
  String? editingChatId;
  TextEditingController renameController = TextEditingController();

  List<Chat> get chats => _chats;
  String? get currentChatId => _currentChatId;

  /// 🔥 GET CURRENT MESSAGES
  List<Message> get currentMessages {
    if (_currentChatId == null) return [];

    if (_tempChat != null && _tempChat!.id == _currentChatId) {
      return _tempChat!.messages;
    }

    return _chats
        .firstWhere(
          (chat) => chat.id == _currentChatId,
          orElse: () => Chat(id: '', title: '', messages: []),
        )
        .messages;
  }

  /// 🔥 LOAD CHATS
  Future<void> loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final data = prefs.getString('chats_${user.uid}');

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      _chats = decoded.map((e) => Chat.fromJson(e)).toList();
    } else {
      _chats = [];
    }

    createNewChat();
    notifyListeners();
  }

  /// 🔥 SAVE CHATS
  Future<void> saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final encoded =
        jsonEncode(_chats.map((e) => e.toJson()).toList());

    await prefs.setString('chats_${user.uid}', encoded);
  }

  /// ➕ CREATE NEW CHAT
  void createNewChat() {
    _tempChat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "New Chat",
      messages: [],
    );

    _currentChatId = _tempChat!.id;

    notifyListeners();
  }

  /// 🔁 SWITCH CHAT
  void switchChat(String chatId) {
    if (_chats.any((chat) => chat.id == chatId)) {
      _currentChatId = chatId;

      _tempChat = null;
      editingChatId = null;
      renameController.clear();

      notifyListeners();
    }
  }

  /// 💬 ADD MESSAGE
  void addMessage(Message message) {
    if (_currentChatId == null) return;

    /// TEMP CHAT
    if (_tempChat != null && _tempChat!.id == _currentChatId) {
      _tempChat!.messages.add(message);

      /// Move to main list after first user message
      if (_tempChat!.messages.length == 1 && message.isUser) {
        String text = message.text.trim();

        _tempChat!.title =
            text.length > 30 ? text.substring(0, 30) + "..." : text;

        _chats.insert(0, _tempChat!);
        _tempChat = null;

        saveChats();
      }

      notifyListeners();
      return;
    }

    /// NORMAL CHAT
    final chat =
        _chats.firstWhere((chat) => chat.id == _currentChatId);

    chat.messages.add(message);

    saveChats();
    notifyListeners();
  }

  /// 🚀 SEND MESSAGE
  Future<void> sendMessage(String text) async {
    addMessage(Message(text: text, isUser: true));

    isLoading = true;
    notifyListeners();

    try {
      final fullReply = await ApiService.sendMessage(text);

      String currentText = "";

      /// ADD EMPTY AI MESSAGE
      addMessage(Message(text: "", isUser: false));

      for (int i = 0; i < fullReply.length; i++) {
        await Future.delayed(const Duration(milliseconds: 15));

        currentText += fullReply[i];

        Chat? chat;

        if (_tempChat != null && _tempChat!.id == _currentChatId) {
          chat = _tempChat;
        } else {
          chat = _chats.firstWhere((c) => c.id == _currentChatId);
        }

        chat!.messages.last.text = currentText;

        notifyListeners();
      }

      await saveChats();
    } catch (e) {
      addMessage(
        Message(text: "⚠️ Error: ${e.toString()}", isUser: false),
      );
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✏️ EDIT MESSAGE (🔥 CORE FEATURE)
  Future<void> editMessage(int index, String newText) async {
    if (_currentChatId == null) return;

    Chat? chat;

    if (_tempChat != null && _tempChat!.id == _currentChatId) {
      chat = _tempChat;
    } else {
      chat = _chats.firstWhere((c) => c.id == _currentChatId);
    }

    if (chat == null || index >= chat.messages.length) return;

    /// 🔥 REMOVE ALL MESSAGES AFTER EDITED ONE
    chat.messages = chat.messages.sublist(0, index + 1);

    /// 🔥 UPDATE TEXT
    chat.messages[index].text = newText;

    notifyListeners();

    /// 🔥 REGENERATE RESPONSE
    isLoading = true;
    notifyListeners();

    try {
      final fullReply = await ApiService.sendMessage(newText);

      String currentText = "";

      /// ADD EMPTY AI MESSAGE
      chat.messages.add(Message(text: "", isUser: false));

      for (int i = 0; i < fullReply.length; i++) {
        await Future.delayed(const Duration(milliseconds: 15));

        currentText += fullReply[i];

        chat.messages.last.text = currentText;

        notifyListeners();
      }

      await saveChats();
    } catch (e) {
      chat.messages.add(
        Message(text: "⚠️ Error: ${e.toString()}", isUser: false),
      );
    }

    isLoading = false;
    notifyListeners();
  }

  /// ❌ DELETE CHAT
  void deleteChat(String chatId) {
    _chats.removeWhere((chat) => chat.id == chatId);

    if (_chats.isEmpty) {
      createNewChat();
    } else {
      _currentChatId = _chats.first.id;
    }

    saveChats();
    notifyListeners();
  }

  /// ✏️ RENAME START
  void startRenaming(String chatId) {
    editingChatId = chatId;

    final chat = _chats.firstWhere((c) => c.id == chatId);
    renameController.text = chat.title;

    notifyListeners();
  }

  /// 💾 SAVE RENAME
  void saveRename(String chatId) {
    final chat = _chats.firstWhere((c) => c.id == chatId);

    chat.title = renameController.text.trim().isEmpty
        ? "New Chat"
        : renameController.text.trim();

    editingChatId = null;
    renameController.clear();

    saveChats();
    notifyListeners();
  }
}