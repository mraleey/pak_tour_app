import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/route_controller.dart';
import '../models/route_plan_model.dart';
import '../utils/app_colors.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_button.dart';
import 'place_detail_screen.dart';

class RoutePlannerScreen extends StatefulWidget {
  @override
  _RoutePlannerScreenState createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> with SingleTickerProviderStateMixin {
  final RouteController _routeController = Get.find<RouteController>();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveRouteTab(),
                _buildAllRoutesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      color: AppColors.primaryColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        tabs: [
          Tab(text: 'Active Route'),
          Tab(text: 'All Routes'),
        ],
      ),
    );
  }
  
  Widget _buildActiveRouteTab() {
    return Obx(() {
      if (_routeController.isLoading.value) {
        return LoadingIndicator();
      }
      
      if (_routeController.isGeneratingRoute.value) {
        return _buildGeneratingRoute();
      }
      
      if (_routeController.currentRoutePlan.value == null) {
        return _buildNoActiveRoute();
      }
      
      return _buildRouteDetails(_routeController.currentRoutePlan.value!);
    });
  }
  
  Widget _buildAllRoutesTab() {
    return Obx(() {
      if (_routeController.isLoading.value) {
        return LoadingIndicator();
      }
      
      if (_routeController.routePlans.isEmpty) {
        return _buildNoRoutes();
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _routeController.routePlans.length,
        itemBuilder: (context, index) {
          final routePlan = _routeController.routePlans[index];
          return _buildRouteCard(routePlan);
        },
      );
    });
  }
  
  Widget _buildNoActiveRoute() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Active Route Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Create a route plan from your wishlist\nor activate an existing one',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          CustomButton(
            text: 'Go to Wishlist',
            onPressed: () {
              // Switch to wishlist tab
              Get.back();
              Get.find<RouteController>();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoRoutes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Route Plans Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add places to your wishlist and\ngenerate a route plan',
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
  
  Widget _buildGeneratingRoute() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Generating Your Route Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Obx(() => Text(
            _routeController.generationStatus.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildRouteCard(RoutePlanModel routePlan) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    routePlan.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (routePlan.isActive)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${routePlan.createdAt.day}/${routePlan.createdAt.month}/${routePlan.createdAt.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.place, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${routePlan.steps.length} destinations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: routePlan.completionPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            SizedBox(height: 4),
            Text(
              '${routePlan.completionPercentage.toStringAsFixed(0)}% completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _showRouteDetailsBottomSheet(routePlan);
                  },
                  child: Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
                if (!routePlan.isActive)
                  ElevatedButton(
                    onPressed: () {
                      _routeController.setActiveRoutePlan(routePlan.id);
                    },
                    child: Text('Set Active'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (routePlan.isActive)
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
                    child: Text('View Active'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRouteDetails(RoutePlanModel routePlan) {
    return Column(
      children: [
        _buildRouteMap(routePlan),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routePlan.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildRouteStats(routePlan),
                SizedBox(height: 16),
                _buildAIRecommendation(routePlan),
                SizedBox(height: 24),
                Text(
                  'Your Journey (${routePlan.steps.length} destinations)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildStepsList(routePlan),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRouteMap(RoutePlanModel routePlan) {
    // Would use Google Maps here to display the route
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          'Map View',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildRouteStats(RoutePlanModel routePlan) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            title: 'Duration',
            value: '${(routePlan.totalTimeMinutes / 60).toStringAsFixed(1)} hrs',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.straighten,
            title: 'Distance',
            value: '${routePlan.totalDistanceKm.toStringAsFixed(1)} km',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            title: 'Progress',
            value: '${routePlan.completionPercentage.toStringAsFixed(0)}%',
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIRecommendation(RoutePlanModel routePlan) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assistant,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                'AI Recommendation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            routePlan.aiRecommendation,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepsList(RoutePlanModel routePlan) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: routePlan.steps.length,
      itemBuilder: (context, index) {
        final step = routePlan.steps[index];
        final isLastStep = index == routePlan.steps.length - 1;
        
        return InkWell(
          onTap: () {
            Get.to(() => PlaceDetailScreen(place: step.place));
          },
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: step.place.isVisited
                              ? Colors.green
                              : AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: step.place.isVisited
                              ? Icon(Icons.check, color: Colors.white, size: 18)
                              : Text(
                                  '${step.order}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      if (!isLastStep)
                        Container(
                          width: 2,
                          height: 50,
                          color: Colors.grey[300],
                        ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.place.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: step.place.isVisited
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          step.place.description.length > 100
                              ? '${step.place.description.substring(0, 100)}...'
                              : step.place.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            if (index > 0)
                              Text(
                                '${step.distanceKm.toStringAsFixed(1)} km • ${step.estimatedTimeMinutes} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            Spacer(),
                            if (!step.place.isVisited)
                              OutlinedButton(
                                onPressed: () {
                                  _routeController.updateVisitStatus(
                                    routePlan.id,
                                    step.place.id,
                                    true,
                                  );
                                },
                                child: Text('Mark Visited'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size(0, 36),
                                ),
                              ),
                            if (step.place.isVisited)
                              OutlinedButton(
                                onPressed: () {
                                  _routeController.updateVisitStatus(
                                    routePlan.id,
                                    step.place.id,
                                    false,
                                  );
                                },
                                child: Text('Unmark'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size(0, 36),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRouteDetailsBottomSheet(RoutePlanModel routePlan) {
    final RouteController _routeController = Get.find<RouteController>();

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          routePlan.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    Divider(),
                    _buildRouteStats(routePlan),
                    SizedBox(height: 16),

                    // AI Recommendation
                    Text(
                      'AI Recommendation:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      routePlan.aiRecommendation,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),

                    // Destinations
                    Text(
                      'Destinations:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: routePlan.steps.length,
                      itemBuilder: (context, index) {
                        final step = routePlan.steps[index];
                        return ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: step.place.isVisited
                                  ? Colors.green
                                  : AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: step.place.isVisited
                                  ? Icon(Icons.check, color: Colors.white, size: 16)
                                  : Text(
                                '${step.order}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            step.place.name,
                            style: TextStyle(
                              decoration: step.place.isVisited
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: index > 0
                              ? Text(
                            '${step.distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          )
                              : null,
                        );
                      },
                    ),
                    SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!routePlan.isActive)
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              _routeController.setActiveRoutePlan(routePlan.id);
                            },
                            child: Text('Set as Active'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        OutlinedButton(
                          onPressed: () {
                            Get.back();
                            _showDeleteConfirmation(routePlan);
                          },
                          child: Text('Delete Plan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmation(RoutePlanModel routePlan) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Route Plan'),
        content: Text('Are you sure you want to delete this route plan?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _routeController.deleteRoutePlan(routePlan.id);
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
