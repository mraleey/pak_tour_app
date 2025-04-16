import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/place_controller.dart';
import '../controllers/route_controller.dart';
import '../models/place_model.dart';
import '../utils/app_colors.dart';
import '../widgets/place_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_button.dart';
import 'place_detail_screen.dart';
import 'route_planner_screen.dart';

class WishlistScreen extends StatelessWidget {
  final PlaceController _placeController = Get.find<PlaceController>();
  final RouteController _routeController = Get.find<RouteController>();
  final TextEditingController _routeNameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_placeController.isWishlistLoading.value) {
          return LoadingIndicator();
        }
        
        if (_placeController.wishlistPlaces.isEmpty) {
          return _buildEmptyWishlist();
        }
        
        return _buildWishlistContent(context);
      }),
      floatingActionButton: Obx(() {
        if (_placeController.wishlistPlaces.isNotEmpty) {
          return FloatingActionButton.extended(
            onPressed: () => _showGenerateRouteDialog(context),
            label: Text('Generate Route'),
            icon: Icon(Icons.route),
            backgroundColor: AppColors.primaryColor,
          );
        }
        return SizedBox.shrink();
      }),
    );
  }
  
  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add places you want to visit in Pakistan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWishlistContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Wishlist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '${_placeController.wishlistPlaces.length} places to visit',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: _placeController.wishlistPlaces.length,
            itemBuilder: (context, index) {
              final place = _placeController.wishlistPlaces[index];
              return Dismissible(
                key: Key(place.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _placeController.removeFromWishlist(place);
                },
                child: PlaceCard(
                  place: place,
                  onTap: () {
                    Get.to(() => PlaceDetailScreen(place: place));
                  },
                  onWishlistTap: () {
                    _placeController.removeFromWishlist(place);
                  },
                  isInWishlist: true,
                  showVisitedStatus: true,
                  onVisitedChanged: (value) {
                    if (value) {
                      _placeController.markPlaceAsVisited(place);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _showGenerateRouteDialog(BuildContext context) {
    _routeNameController.text = 'My Pakistan Tour ${DateTime.now().day}/${DateTime.now().month}';
    
    Get.dialog(
      AlertDialog(
        title: Text('Generate Route Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create an optimized route to visit all your wishlist places.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _routeNameController,
              decoration: InputDecoration(
                labelText: 'Route Plan Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_routeNameController.text.isEmpty) {
                return;
              }
              
              Get.back();
              
              final routePlan = await _routeController.generateRoutePlan(
                name: _routeNameController.text,
                places: _placeController.wishlistPlaces,
              );
              
              if (routePlan != null) {
                Get.to(() => RoutePlannerScreen());
              }
            },
            child: Text('Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
