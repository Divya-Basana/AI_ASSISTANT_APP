import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/typing_indicator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  
void _listen() async {
  if (!_isListening) {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);

      /// 🌐 👉 ADD YOUR CODE HERE
      List<String> supportedLocales = [
        "en_US",
        "hi_IN",
        "te_IN",
      ];

      String localeId = "en_US";

      try {
        var systemLocale = await _speech.systemLocale();
        localeId = systemLocale?.localeId ?? "en_US";

        if (!supportedLocales.contains(localeId)) {
          localeId = "en_US"; // fallback
        }
      } catch (e) {
        localeId = "en_US";
      }

      /// 🎤 START LISTENING
      _speech.listen(
        localeId: localeId, // 🔥 USE HERE
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10),

        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
      );
    }
  } else {
    setState(() => _isListening = false);
    _speech.stop();
  }
}
  /// 🔥 INLINE EDIT STATE
  int? editingIndex;
  TextEditingController editController = TextEditingController();

  /// 🔥 AUTO SCROLL
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🔥 SEND MESSAGE
  void sendMessage(ChatProvider chatProvider, String text) {
    if (text.trim().isEmpty) return;

    chatProvider.sendMessage(text.trim());
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.currentMessages;

        final isKeyboardOpen =
            MediaQuery.of(context).viewInsets.bottom > 0;

        scrollToBottom();

        return Container(
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
          child: Column(
            children: [
              /// 🔥 CHAT AREA
              Expanded(
                child: messages.isEmpty && !isKeyboardOpen
                    ? buildWelcomeUI(chatProvider)
                    : ListView.builder(
                        controller: scrollController,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            alignment: msg.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints:
                                  const BoxConstraints(maxWidth: 300),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: msg.isUser
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF2563EB),
                                          Color(0xFF22D3EE),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF1E293B),
                                          Color(0xFF0F172A),
                                        ],
                                      ),
                                borderRadius:
                                    BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  )
                                ],
                              ),

                              /// 🔥 INLINE EDIT OR NORMAL VIEW
                              child: editingIndex == index && msg.isUser
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// EDIT FIELD
                                        TextField(
                                          controller: editController,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          maxLines: null,
                                          autofocus: true,
                                          decoration:
                                              const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        /// BUTTONS
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            /// CANCEL
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  editingIndex = null;
                                                  editController.clear();
                                                });
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color:
                                                        Colors.white70),
                                              ),
                                            ),

                                            /// SAVE
                                            ElevatedButton(
                                              onPressed: () {
                                                final newText =
                                                    editController.text
                                                        .trim();
                                                if (newText.isEmpty)
                                                  return;

                                                Provider.of<ChatProvider>(
                                                        context,
                                                        listen: false)
                                                    .editMessage(
                                                        index, newText);

                                                setState(() {
                                                  editingIndex = null;
                                                  editController.clear();
                                                });
                                              },
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF2563EB),
                                              ),
                                              child: const Text("Save"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )

                                  /// 🔥 NORMAL MESSAGE VIEW
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SelectableText(
                                          msg.text,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            height: 1.5,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            /// COPY
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                      text: msg.text),
                                                );

                                                ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text("Copied")),
                                                );
                                              },
                                              child: const Icon(
                                                Icons.copy,
                                                size: 14,
                                                color:
                                                    Colors.white70,
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            /// EDIT BUTTON
                                            if (msg.isUser)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    editingIndex = index;
                                                    editController.text =
                                                        msg.text;
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.edit,
                                                  size: 14,
                                                  color:
                                                      Colors.white70,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
              ),

              /// 🔥 TYPING INDICATOR
              if (chatProvider.isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.smart_toy,
                          color: Color(0xFF22D3EE)),
                      SizedBox(width: 10),
                      TypingIndicator(),
                    ],
                  ),
                ),

              /// 🔥 INPUT AREA (NORMAL ONLY)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF020617),
                ),
                child: Row(
  children: [
    /// 🎤 MIC BUTTON
  Container(
  decoration: BoxDecoration(
    color: _isListening
        ? Colors.redAccent
        : const Color(0xFF1E293B),
    shape: BoxShape.circle,
    boxShadow: _isListening
        ? [
            BoxShadow(
              color: Colors.red.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ]
        : [],
  ),
  child: IconButton(
    icon: Icon(
      _isListening ? Icons.mic : Icons.mic_none,
      color: Colors.white,
    ),
    onPressed: _listen,
  ),
),

    const SizedBox(width: 8),

    /// 💬 TEXT FIELD
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white10),
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: null,
          textInputAction: TextInputAction.send,
          onSubmitted: (value) =>
              sendMessage(chatProvider, value),
          decoration: const InputDecoration(
            hintText: "Speak or type...",
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
        ),
      ),
    ),

    const SizedBox(width: 8),

    /// 🚀 SEND BUTTON
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF22D3EE),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: () =>
            sendMessage(chatProvider, controller.text),
      ),
    ),
  ],
),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔥 WELCOME UI (UNCHANGED)
  Widget buildWelcomeUI(ChatProvider provider) {
    List<String> suggestions = [
      "Explain AI in simple terms",
      "Write a professional email",
      "Give coding interview tips",
      "Create a study plan",
    ];

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "AI ASSISTANT ✨",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "How can I help you today?",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 30),

            ...suggestions.map((text) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 6),
                child: InkWell(
                  onTap: () {
                    provider.createNewChat();
                    provider.sendMessage(text);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF0F172A),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFF22D3EE),
                            size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}