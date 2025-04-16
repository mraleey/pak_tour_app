import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pak_tour_app_final/views/add_place.dart';

import '../controllers/auth_controller.dart';
import '../controllers/place_controller.dart';
import '../controllers/route_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/place_card.dart';
import '../widgets/loading_indicator.dart';
import '../app_constants.dart';
import 'wishlist_screen.dart';
import 'route_planner_screen.dart';
import 'chat_assistant_screen.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final PlaceController _placeController = Get.find<PlaceController>();
  final RouteController _routeController = Get.find<RouteController>();
  
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _placeController.fetchAllPlaces();
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
     return   _placeController.fetchAllPlaces();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pakistan Tourism'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _authController.logout();
              },
            ),
          ],
        ),
        body: _getPage(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_city),
              label: 'Add Place',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Routes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return WishlistScreen();
        case 2:
        return AddPlaceScreen();
      case 3:
        return RoutePlannerScreen();
      case 4:
        return ChatAssistantScreen();
      default:
        return _buildHomeScreen();
    }
  }
  
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 20),
          _buildActivePlanSection(),
          SizedBox(height: 20),
          _buildPopularDestinationsSection(),
          SizedBox(height: 20),
          _buildAllDestinationsSection(),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeSection() {

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome${_authController.userModel.value != null ? ', ${_authController.userModel.value!.name}' : ''}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Discover the beauty of Pakistan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 20),
          Container(

            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  final place = _placeController.allPlaces[int.parse(value)];
                  Get.to(() => PlaceDetailScreen(place: place,));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivePlanSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Active Route Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Obx(() {
            if (_routeController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (_routeController.currentRoutePlan.value == null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No active route plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Add places to your wishlist and generate a route plan to explore Pakistan efficiently.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2; // Switch to Routes tab
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Create Route Plan'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final plan = _routeController.currentRoutePlan.value!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          '${plan.steps.length} destinations',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(width: 15),
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          '${(plan.totalTimeMinutes / 60).toStringAsFixed(1)} hours',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: plan.completionPercentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${plan.completionPercentage.toStringAsFixed(0)}% completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 3; // Switch to Routes tab
                        });
                      },
                      child: Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildPopularDestinationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Popular Destinations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: Obx(() {
            if (_placeController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (_placeController.allPlaces.isEmpty) {
              return Center(
                child: Text('No destinations found'),
              );
            }
            
            // Filter to show only top rated places
            final popularPlaces = _placeController.allPlaces
                .where((place) => place.rating >= 4.0)
                .take(10)
                .toList();
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: popularPlaces.length,
              itemBuilder: (context, index) {
                final place = popularPlaces[index];
                return Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => PlaceDetailScreen(place: place));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                            image: DecorationImage(
                              image: place.imageUrl == '' ? NetworkImage(place.imageUrl) : AssetImage('assets/images/islamabad.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          place.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 3),
                            Text(
                              place.rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildAllDestinationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Pakistan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Obx(() {
            if (_placeController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (_placeController.allPlaces.isEmpty) {
              return Center(
                child: Text('No destinations found'),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _placeController.allPlaces.length,
              itemBuilder: (context, index) {
                final place = _placeController.allPlaces[index];
                return PlaceCard(
                  place: place,
                  onTap: () {
                    Get.to(() => PlaceDetailScreen(place: place));
                  },
                  onWishlistTap: () {
                    if (_placeController.isInWishlist(place.id)) {
                      _placeController.removeFromWishlist(place);
                    } else {
                      _placeController.addToWishlist(place);
                    }
                  },
                  isInWishlist: _placeController.isInWishlist(place.id),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
