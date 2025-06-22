import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String _geminiApiKey = "AIzaSyC4_9eqwRPUgrPur6ieIa1Z_-AYvznSgwA";
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
    _chat = _model.startChat();
  }

  Future<String> _getAIResponse(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? "Aucune réponse de Gemini.";
    } on GenerativeAIException catch (e) {
      return "Erreur Gemini API: ${e.message}";
    } catch (e) {
      return "Erreur inattendue: ${e.toString()}";
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final aiResponse = await _getAIResponse(text);
      setState(() {
        _messages.add(_Message(aiResponse, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message("Erreur: $e", isUser: false));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessage(_Message msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF4E4FEB),
                radius: 18,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
              ),
            ),
          Flexible(
            child:
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                                colors: [Color(0xFF4E4FEB), Color(0xFF1A1A2E)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFF1F5FB), Color(0xFFE3E8F0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 20),
                        ),
                        border: isUser
                            ? null
                            : Border.all(
                                color: const Color(
                                  0xFF4E4FEB,
                                ).withOpacity(0.18),
                                width: 1.5,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? const Color(0xFF4E4FEB).withOpacity(0.13)
                                : const Color(0xFF1A1A2E).withOpacity(0.10),
                            blurRadius: isUser ? 10 : 16,
                            offset: Offset(0, isUser ? 4 : 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isUser)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Assistant Pavlix",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4E4FEB),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.verified,
                                  color: Color(0xFF4E4FEB),
                                  size: 16,
                                ),
                              ],
                            ),
                          if (!isUser) const SizedBox(height: 6),
                          Text(
                            msg.text,
                            style: GoogleFonts.montserrat(
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                              fontSize: 15,
                              fontWeight: isUser
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: isUser ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 100.ms)
                    .slideX(begin: isUser ? 0.2 : -0.2, curve: Curves.easeOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return Column(
            children: [
              // Bannière en haut
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Assistant IA",
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Le contenu principal
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF5F5F7), Color(0xFFEAEAEC)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessage(
                                _messages[_messages.length - 1 - index],
                              );
                            },
                          ),
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF4E4FEB),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: "Écrivez votre message...",
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                      hintStyle: GoogleFonts.montserrat(),
                                    ),
                                    style: GoogleFonts.montserrat(),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CircleAvatar(
                                    backgroundColor: _isLoading
                                        ? Colors.grey
                                        : const Color(0xFF4E4FEB),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _sendMessage,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildCustomBottomNav(
        context,
        2,
      ), // 2 = index du chat
    );
  }
}

// Ajoute cette fonction dans chat_page.dart (ou importe-la depuis main.dart)
Widget _buildCustomBottomNav(BuildContext context, int selectedIndex) {
  return Container(
    height: 80,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1976D2).withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(context, Icons.home, 'Accueil', 0, selectedIndex),
        _navItem(context, Icons.history, 'Historique', 1, selectedIndex),
        _navItem(context, Icons.chat_bubble_outline, 'Chat', 2, selectedIndex),
        _navItem(context, Icons.settings, 'Paramètres', 3, selectedIndex),
      ],
    ),
  );
}

Widget _navItem(
  BuildContext context,
  IconData icon,
  String label,
  int index,
  int selectedIndex,
) {
  bool isSelected = selectedIndex == index;
  return GestureDetector(
    onTap: () {
      if (index == 0) Navigator.pushNamed(context, '/');
      if (index == 1) Navigator.pushNamed(context, '/historique');
      if (index == 2) Navigator.pushNamed(context, '/chat');
      if (index == 3) Navigator.pushNamed(context, '/settings');
    },
    child: AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Message {
  final String text;
  final bool isUser;
  _Message(this.text, {required this.isUser});
}
