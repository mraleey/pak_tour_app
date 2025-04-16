import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../models/place_model.dart';

class AIService {
  final String _routePlanningEndpoint =
      AppConstants.llamaRoutePlanningModelEndpoint;
  final String _chatModelEndpoint = AppConstants.llamaChatModelEndpoint;

  // Get API key from environment variables
  // String get _apiKey => dotenv.env['LLAMA_API_KEY'] ?? '';

  Future<String> getRoutePlanRecommendation(List<PlaceModel> places) async {
    try {
      // if (_apiKey.isEmpty) {
      //   print('API key is missing');
      //   return _getFallbackRecommendation(places);
      // }

      // Format places into a string for the prompt
      String placesText = places
          .map((place) =>
              '- ${place.name}: ${place.description.substring(0, place.description.length > 100 ? 100 : place.description.length)}...')
          .join('\n');

      // Create prompt
      String prompt = '''
I need to plan an efficient route to visit the following tourist destinations in Pakistan:

$placesText

Please analyze these locations and provide:
1. The most efficient order to visit these places to minimize travel time and distance
2. Estimated travel times between each location
3. Recommended mode of transportation between each place
4. Any seasonal considerations I should be aware of
5. Suggested duration of stay at each location

Provide a comprehensive route plan with tips for the best experience.
''';

      // Make API request
      final response = await http.post(
        Uri.parse(_routePlanningEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'prompt': prompt,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['text'];
      } else {
        print('Error from AI service: ${response.body}');
        return _getFallbackRecommendation(places);
      }
    } catch (e) {
      print('Error getting route recommendation: $e');
      return _getFallbackRecommendation(places);
    }
  }

  Future getChatResponse(String userMessage,
      List<Map<String, dynamic>> conversationHistory) async {
    try {
      // if (_apiKey.isEmpty) {
      //   print('API key is missing');
      //   return _getFallbackChatResponse(userMessage);
      // }

      // Add context about Pakistan tourism
      String systemPrompt = '''
You are a helpful assistant specialized in Pakistan tourism. You know about popular tourist destinations, 
local customs, travel tips, cultural insights, historical sites, natural landmarks, and practical information for traveling in Pakistan.
Always provide accurate, respectful, and helpful information. If you don't know something, admit it rather than making up information.
''';

      // Prepare messages array with system prompt, conversation history, and new user message
      List<Map<String, dynamic>> messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage}
      ];

      // Make API request
      final response = await http.post(
        Uri.parse(_chatModelEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Error from AI service: ${response.body}');
        return _getFallbackChatResponse(userMessage);
      }
    } catch (e) {
      print('Error getting chat response: $e');
      return _getFallbackChatResponse(userMessage);
    }
  }

  String _getFallbackRecommendation(List<PlaceModel> places) {
    // Provide a reasonable fallback when AI service is unavailable
    return '''
Based on the destinations in your wishlist, here's a suggested route plan:

1. Start with urban destinations first, then move towards northern areas.
2. For northern destinations like Hunza, Skardu and Fairy Meadows, summer (May-September) is the best time to visit.
3. Allow 2-3 days for major destinations and 1 day for smaller attractions.
4. Use domestic flights to cover long distances between major cities.
5. For northern areas, consider hiring a local driver familiar with mountain roads.

This route minimizes backtracking and optimizes your travel experience in Pakistan.
''';
  }

  Object _getFallbackChatResponse(String userMessage) {
    // Provide a reasonable fallback when AI service is unavailable
    if (userMessage.toLowerCase().contains('weather')) {
      return 'Pakistan has diverse weather patterns. The southern areas are hot and dry, while northern mountains have cool summers and cold winters. The best time to visit most of Pakistan is during spring (March-May) and autumn (September-November) when the weather is pleasant.';
    } else if (userMessage.toLowerCase().contains('food') ||
        userMessage.toLowerCase().contains('cuisine')) {
      return 'Pakistani cuisine is diverse and flavorful! Must-try dishes include Biryani, Karahi, Nihari, Chapli Kebab, and various bread like Naan and Paratha. Each region has its own specialties - try Sajji in Balochistan, Chapli Kebab in Khyber Pakhtunkhwa, and seafood in coastal areas.';
    } else if (userMessage.toLowerCase().contains('transport') ||
        userMessage.toLowerCase().contains('travel')) {
      return 'In Pakistan, you can travel by air, train, bus, or taxi. Major cities are connected by domestic flights. Pakistan Railways offers an economical way to see the country. For northern areas, hiring a local driver is often the best option as roads can be challenging. Within cities, ride-hailing apps are convenient.';
    } else {
      return Text(
          "I apologize, but I cannot provide a detailed response right now. Please try asking a different question about Pakistan tourism, and I'll do my best to help!");
    }
  }
}
