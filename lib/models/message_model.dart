class Message {
  String text;
  bool isUser;

  Message({
    required this.text,
    required this.isUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }
}