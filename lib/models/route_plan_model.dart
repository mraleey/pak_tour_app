import 'package:cloud_firestore/cloud_firestore.dart';
import 'place_model.dart';

class RouteStepModel {
  final int order;
  final PlaceModel place;
  final String travelMode; // driving, walking, etc.
  final int estimatedTimeMinutes;
  final double distanceKm;
  final Map<String, dynamic> directionsInfo;
  
  RouteStepModel({
    required this.order,
    required this.place,
    required this.travelMode,
    required this.estimatedTimeMinutes,
    required this.distanceKm,
    required this.directionsInfo,
  });
  
  factory RouteStepModel.fromMap(Map<String, dynamic> map) {
    return RouteStepModel(
      order: map['order'],
      place: PlaceModel.fromMap(map['place'], id: map['placeId']),
      travelMode: map['travelMode'],
      estimatedTimeMinutes: map['estimatedTimeMinutes'],
      distanceKm: map['distanceKm'],
      directionsInfo: map['directionsInfo'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'place': place.toMap(),
      'travelMode': travelMode,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'distanceKm': distanceKm,
      'directionsInfo': directionsInfo,
    };
  }
}

class RoutePlanModel {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RouteStepModel> steps;
  final int totalTimeMinutes;
  final double totalDistanceKm;
  final String aiRecommendation;
  final bool isActive;
  
  RoutePlanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.steps,
    required this.totalTimeMinutes,
    required this.totalDistanceKm,
    required this.aiRecommendation,
    this.isActive = false,
  });
  
  factory RoutePlanModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return RoutePlanModel(
      id: id ?? map['id'],
      userId: map['userId'],
      name: map['name'],
      createdAt: map['createdAt'].toDate(),
      updatedAt: map['updatedAt'].toDate(),
      steps: (map['steps'] as List)
          .map((stepMap) => RouteStepModel.fromMap(stepMap))
          .toList(),
      totalTimeMinutes: map['totalTimeMinutes'],
      totalDistanceKm: map['totalDistanceKm'],
      aiRecommendation: map['aiRecommendation'],
      isActive: map['isActive'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'steps': steps.map((step) => step.toMap()).toList(),
      'totalTimeMinutes': totalTimeMinutes,
      'totalDistanceKm': totalDistanceKm,
      'aiRecommendation': aiRecommendation,
      'isActive': isActive,
    };
  }
  
  // Get remaining places that have not been visited
  List<PlaceModel> get remainingPlaces {
    return steps
        .where((step) => !step.place.isVisited)
        .map((step) => step.place)
        .toList();
  }
  
  // Get visited places
  List<PlaceModel> get visitedPlaces {
    return steps
        .where((step) => step.place.isVisited)
        .map((step) => step.place)
        .toList();
  }
  
  // Get completion percentage
  double get completionPercentage {
    if (steps.isEmpty) return 0.0;
    return (visitedPlaces.length / steps.length) * 100;
  }

  RoutePlanModel copyWith({List<RouteStepModel>? steps, String?  id, bool? isActive}) {
    return RoutePlanModel(
      id: id ?? this.id,
      userId: userId,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      steps: steps ?? this.steps,
      totalTimeMinutes: totalTimeMinutes,
      totalDistanceKm: totalDistanceKm,
      aiRecommendation: aiRecommendation,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? relatedPlaceId;
  
  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.relatedPlaceId,
  });
  
  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id ?? map['id'],
      userId: map['userId'],
      message: map['message'],
      isUser: map['isUser'],
      timestamp: map['timestamp'].toDate(),
      relatedPlaceId: map['relatedPlaceId'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp,
      'relatedPlaceId': relatedPlaceId,
    };
  }
}
