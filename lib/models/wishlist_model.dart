import 'package:pak_tour_app/models/place_model.dart';

class WishlistModel {
  final String id;
  final String userId;
  final List<PlaceModel> places;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistModel({
    required this.id,
    required this.userId,
    required this.places,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WishlistModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return WishlistModel(
      id: id ?? map['id'],
      userId: map['userId'],
      places: (map['places'] as List)
          .map((placeMap) => PlaceModel.fromMap(placeMap))
          .toList(),
      createdAt: map['createdAt'].toDate(),
      updatedAt: map['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'places': places.map((place) => place.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}