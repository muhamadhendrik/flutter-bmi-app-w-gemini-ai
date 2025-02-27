import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  final List<String> words;
  int displayedWords;

  Message({
    required this.text,
    required this.isUser,
  })  : words = text.split(' '),
        displayedWords = 0;

  String get displayText {
    return words.take(displayedWords).join(' ');
  }

  bool get isComplete => displayedWords >= words.length;
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isGenerating = false;

  final Gemini gemini =
      Gemini.init(apiKey: 'AIzaSyCpr21sjPL8aE6V-DxarU3HQt0WNH1NEME');

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks berhasil disalin'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add(Message(text: userMessage, isUser: true));
      _isGenerating = true;
    });
    _controller.clear();

    try {
      final response = await gemini.text(userMessage);
      final aiMessage = response?.output ?? "No response from AI";
      final cleanResponse = aiMessage.replaceAll('*', '');

      final message = Message(text: cleanResponse, isUser: false);
      setState(() {
        _messages.add(message);
        _isGenerating = false;
      });

      for (int i = 1; i <= message.words.length; i++) {
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            message.displayedWords = i;
          });
        }
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(text: "Error: ${e.toString()}", isUser: false));
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat AI Gemini",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 84, 128, 172),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () => _copyToClipboard(
                      message.isUser ? message.text : message.displayText,
                      context,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color.fromARGB(255, 58, 102, 138)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            message.isUser ? message.text : message.displayText,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          if (!message.isUser) ...[
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _copyToClipboard(
                                message.displayText,
                                context,
                              ),
                              child: Icon(
                                Icons.copy,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isGenerating ? null : _sendMessage,
                  color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
