import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_model.dart';
import '../app_constants.dart';


class MapService {
  // Get API key from environment variables
  // String get _apiKey => dotenv.env['MAPS_API_KEY'] ?? AppConstants.mapsApiKey;
  
  final String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  Future<List<Map<String, dynamic>>> getOptimalRoute(List<PlaceModel> places) async {
    try {
      if (places.length <= 1) {
        return [];
      }
      
      List<Map<String, dynamic>> directionsData = [];
      
      // For each adjacent pair of places, get directions
      for (int i = 0; i < places.length - 1; i++) {
        PlaceModel origin = places[i];
        PlaceModel destination = places[i + 1];
        
        Map<String, dynamic> directions = await _getDirections(
          LatLng(origin.location.latitude, origin.location.longitude),
          LatLng(destination.location.latitude, destination.location.longitude),
        );
        
        directionsData.add(directions);
      }
      
      return directionsData;
    } catch (e) {
      print('Error getting optimal route: $e');
      return _getFallbackRouteData(places);
    }
  }
  
  Future<Map<String, dynamic>> _getDirections(LatLng origin, LatLng destination) async {
    try {
      // if (_apiKey.isEmpty) {
      //   print('Maps API key is missing');
      //   return _getFallbackDirectionsData(origin, destination);
      // }
      
      final response = await http.get(
        Uri.parse('$_directionsBaseUrl?'
            'origin=${origin.latitude},${origin.longitude}'
            '&destination=${destination.latitude},${destination.longitude}'
            '&mode=driving'
            // '&key=$_apiKey'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          return {
            'distance': leg['distance']['value'] / 1000, // Convert to km
            'duration': leg['duration']['value'] ~/ 60, // Convert to minutes
            'startAddress': leg['start_address'],
            'endAddress': leg['end_address'],
            'steps': leg['steps'],
            'polyline': route['overview_polyline']['points'],
            'travelMode': 'driving',
          };
        } else {
          print('Directions API error: ${data['status']}');
          return _getFallbackDirectionsData(origin, destination);
        }
      } else {
        print('Directions API error: ${response.statusCode}');
        return _getFallbackDirectionsData(origin, destination);
      }
    } catch (e) {
      print('Error fetching directions: $e');
      return _getFallbackDirectionsData(origin, destination);
    }
  }
  
  Map<String, dynamic> _getFallbackDirectionsData(LatLng origin, LatLng destination) {
    // Calculate rough distance using Haversine formula
    double distance = _calculateDistance(origin, destination);
    
    // Assuming average speed of 50 km/h for driving in Pakistan
    int duration = (distance * 60 / 50).round(); // Convert to minutes
    
    return {
      'distance': distance,
      'duration': duration,
      'startAddress': 'Origin',
      'endAddress': 'Destination',
      'steps': [],
      'polyline': '',
      'travelMode': 'driving',
    };
  }
  
  List<Map<String, dynamic>> _getFallbackRouteData(List<PlaceModel> places) {
    List<Map<String, dynamic>> fallbackData = [];
    
    for (int i = 0; i < places.length - 1; i++) {
      PlaceModel origin = places[i];
      PlaceModel destination = places[i + 1];
      
      LatLng originLatLng = LatLng(origin.location.latitude, origin.location.longitude);
      LatLng destinationLatLng = LatLng(destination.location.latitude, destination.location.longitude);
      
      fallbackData.add(_getFallbackDirectionsData(originLatLng, destinationLatLng));
    }
    
    return fallbackData;
  }
  
  double _calculateDistance(LatLng origin, LatLng destination) {
    const double earthRadius = 6371; // in kilometers
    
    double lat1 = origin.latitude * (3.14159265359 / 180);
    double lon1 = origin.longitude * (3.14159265359 / 180);
    double lat2 = destination.latitude * (3.14159265359 / 180);
    double lon2 = destination.longitude * (3.14159265359 / 180);
    
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
        lat1.abs() * lat2.abs() * (dLon / 2).abs() * (dLon / 2).abs();
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
  
  Future<Set<Marker>> getPlaceMarkers(List<PlaceModel> places) async {
    Set<Marker> markers = {};
    
    for (int i = 0; i < places.length; i++) {
      final place = places[i];
      markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.location.latitude, place.location.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.isVisited ? 'Visited' : 'Not visited yet',
          ),
        ),
      );
    }
    
    return markers;
  }
  
  Future<List<Polyline>> getRoutePolylines(List<Map<String, dynamic>> directionsData) async {
    List<Polyline> polylines = [];
    
    try {
      for (int i = 0; i < directionsData.length; i++) {
        final data = directionsData[i];
        
        if (data['polyline'] != null && data['polyline'].isNotEmpty) {
          List<LatLng> points = _decodePolyline(data['polyline']);
          
          polylines.add(
            Polyline(
              polylineId: PolylineId('route_$i'),
              points: points,
              color: Color(_getPolylineColor(i)),
              width: 5,
            ),
          );
        }
      }
      
      return polylines;
    } catch (e) {
      print('Error creating polylines: $e');
      return [];
    }
  }
  
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    
    while (index < len) {
      int b, shift = 0, result = 0;
      
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      
      shift = 0;
      result = 0;
      
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      
      double latitude = lat / 1e5;
      double longitude = lng / 1e5;
      
      poly.add(LatLng(latitude, longitude));
    }
    
    return poly;
  }
  
  // Helper method to get different colors for route segments
  int _getPolylineColor(int index) {
    List<int> colors = [
      0xFF0000FF, // Blue
      0xFF00FF00, // Green
      0xFFFF0000, // Red
      0xFFFF00FF, // Purple
      0xFF00FFFF, // Cyan
      0xFFFFFF00, // Yellow
    ];
    
    return colors[index % colors.length];
  }
}
