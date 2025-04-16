import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';

class ChatController extends GetxController {
  final textController = TextEditingController();
  final messages = <ChatMessageModel>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;

  final String _apiKey = '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';
  final String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessageModel(
      message: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);
    textController.clear();

    isSending.value = true;

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant focused on Pakistan tourism.'},
            {'role': 'user', 'content': text.trim()},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];

        final botMessage = ChatMessageModel(
          message: content.trim(),
          isUser: false,
          timestamp: DateTime.now(),
        );

        messages.add(botMessage);
      } else {
        messages.add(ChatMessageModel(
          message: 'Failed to get response. Try again later.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      messages.add(ChatMessageModel(
        message: 'Error occurred: $e',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isSending.value = false;
    }
  }

  void deleteAllMessages() {
    messages.clear();
  }
}
