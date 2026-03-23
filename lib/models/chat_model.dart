import 'message_model.dart';

class Chat {
  String id;
  String title;
  List<Message> messages;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      title: json['title'] ?? 'New Chat',
      messages: (json['messages'] as List? ?? [])
          .map((e) => Message.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}