import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final GeoPoint location;
  final List<String> categories;
  final double rating;
  final Map<String, dynamic> additionalInfo;
  final bool isVisited;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.categories,
    required this.rating,
    required this.additionalInfo,
    this.isVisited = false,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PlaceModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? const GeoPoint(0.0, 0.0),
      categories: List<String>.from(map['categories'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      additionalInfo: map['additionalInfo'] ?? {},
      isVisited: map['isVisited'] ?? false,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'categories': categories,
      'rating': rating,
      'additionalInfo': additionalInfo,
      'isVisited': isVisited,
    };
  }
  
  PlaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    GeoPoint? location,
    List<String>? categories,
    double? rating,
    Map<String, dynamic>? additionalInfo,
    bool? isVisited,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isVisited: isVisited ?? this.isVisited,
    );
  }
}

