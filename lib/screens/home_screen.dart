import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ChatProvider>(context, listen: false).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    double width = MediaQuery.of(context).size.width;

    Widget buildSidebar() {
      return SafeArea(
        child: Container(
          width: 260,
          color: const Color.fromARGB(255, 41, 43, 49),

          child: Column(
            children: [
              const SizedBox(height: 9),

              /// ➕ NEW CHAT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    provider.createNewChat();

                    if (MediaQuery.of(context).size.width < 600) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "New Chat",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const Divider(color: Colors.grey, height: 1),

              /// 🕘 RECENT
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recent",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              /// 💬 CHAT LIST
              Expanded(
                child: ListView.builder(
                  itemCount: provider.chats.length,
                  itemBuilder: (context, index) {
                    final chat = provider.chats[index];

                    return ListTile(
                      selected: chat.id == provider.currentChatId,
                      selectedTileColor: Color.fromARGB(255, 41, 43, 49),

                      /// ✏️ RENAME
                      title: provider.editingChatId == chat.id
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2B32),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TextField(
                                controller: provider.renameController,
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => provider.saveRename(chat.id),
                                onTapOutside: (_) {
                                  provider.saveRename(chat.id);
                                },
                              ),
                            )
                          : Text(
                              chat.title,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),

                      /// 🔁 SWITCH CHAT
                      onTap: () {
                        provider.switchChat(chat.id);

                        if (width < 600) {
                          Navigator.pop(context);
                        }
                      },

                      /// ⚙️ MENU
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white70),
                        color: const Color(0xFF2A2B32),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'rename',
                            child: Text("Rename"),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete"),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            provider.deleteChat(chat.id);
                          } else if (value == 'rename') {
                            provider.startRenaming(chat.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              /// 🔥 PROFILE SECTION (YOUR STYLE)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ??
                                user?.email?.split('@')[0] ??
                                "User",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          GestureDetector(
                            onTap: () async {
                              try {
                                await FirebaseAuth.instance.signOut();

                                final googleSignIn = GoogleSignIn();
                                if (await googleSignIn.isSignedIn()) {
                                  await googleSignIn.disconnect();
                                  await googleSignIn.signOut();
                                }

                                /// ✅ REDIRECT TO LOGIN
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginScreen()),
                                  (route) => false,
                                );

                              } catch (e) {
                                print("Logout error: $e");
                              }
                            },
                            child: const Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 17,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// 📱 MOBILE
    if (width < 600) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("AI assistant"),
          backgroundColor: const Color.fromARGB(213, 3, 4, 11),
        ),
        drawer: Drawer(child: buildSidebar()),
        body: ChatScreen(),
      );
    }

    /// 💻 DESKTOP
    return Scaffold(
      body: Row(
        children: [
          buildSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: ChatScreen()),
        ],
      ),
    );
  }
}