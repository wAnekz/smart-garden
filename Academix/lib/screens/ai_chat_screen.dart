import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secrets.dart';
import 'garden_data.dart'; // Наша модель данных

class AIChatScreen extends StatefulWidget {
  final GardenData gardenData;

  const AIChatScreen({super.key, required this.gardenData});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // --- КОНФИГУРАЦИЯ GROQ ---
  static const String _groqApiKey = groqApiKey; // from lib/secrets.dart (gitignored)
  static const String _model = 'llama-3.3-70b-versatile';

  @override
  void initState() {
    super.initState();
    _generateWelcomeMessage();
  }
  

  // Создаем приветствие на основе данных датчиков
  void _generateWelcomeMessage() {
    String welcome;
    if (widget.gardenData.temp == 0 && widget.gardenData.humidity == 0) {
      welcome = "Привет! Я ваш агро-помощник. Чтобы я мог проанализировать состояние сада, загляните во вкладку 'Статус'. Чем могу помочь сейчас?";
    } else {
      welcome = "Здравствуйте! Я проанализировал данные: у вас в саду ${widget.gardenData.temp}°C, почва прогрета до ${widget.gardenData.soilTemp}°C, а влажность составляет ${widget.gardenData.soilMoisture}%. Есть вопросы по уходу?";
    }

    _messages.add({"role": "ai", "content": welcome});
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": userText});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Формируем системный промпт с актуальными данными
      final String gardenContext = widget.gardenData.toSystemPrompt();

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {
              "role": "system",
              "content": "Ты — эксперт-агроном. ТЕКУЩИЕ ДАННЫЕ САДА: $gardenContext. "
                  "Твоя задача: давать советы на основе этих цифр. "
                  "Если влажность почвы ниже 30%, советуй полив. "
                  "Если УФ-индекс высокий, предупреди. "
                  "Отвечай кратко (2-3 предложения), дружелюбно и только на русском языке."
            },
            ..._messages.map((m) => {
              "role": m["role"] == "user" ? "user" : "assistant",
              "content": m["content"]
            }).toList(),
          ],
          "temperature": 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String aiText = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add({"role": "ai", "content": aiText});
        });
      } else {
        throw Exception("Ошибка API");
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "content": "Извините, возникли проблемы со связью. Попробуйте позже."});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Агро-Консультант",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index]["role"] == "user";
                return _buildChatBubble(_messages[index]["content"]!, isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("ИИ анализирует данные...", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Text(text,
            style: TextStyle(color: isUser ? Colors.white : Colors.black87, height: 1.4)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 15,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Напишите агроному...",
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              radius: 25,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          )
        ],
      ),
    );
  }
}