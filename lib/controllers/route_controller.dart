import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';
import '../models/route_plan_model.dart';
import '../app_constants.dart';
import '../utils/ui_helpers.dart';
import 'auth_controller.dart';
import 'place_controller.dart';
import '../services/ai_service.dart';
import '../services/map_service.dart';

class RouteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final PlaceController _placeController = Get.find<PlaceController>();
  final AIService _aiService = AIService();
  final MapService _mapService = MapService();
  
  RxList<RoutePlanModel> routePlans = <RoutePlanModel>[].obs;
  Rx<RoutePlanModel?> currentRoutePlan = Rx<RoutePlanModel?>(null);
  
  RxBool isLoading = false.obs;
  RxBool isGeneratingRoute = false.obs;
  RxString generationStatus = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    ever(_authController.firebaseUser, (_) {
      if (_authController.isLoggedIn) {
        fetchRoutePlans();
      } else {
        routePlans.clear();
        currentRoutePlan.value = null;
      }
    });
  }
  
  Future<void> fetchRoutePlans() async {
    if (!_authController.isLoggedIn) return;
    
    try {
      isLoading.value = true;
      
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.routePlansCollection)
          .where('userId', isEqualTo: _authController.firebaseUser.value!.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      routePlans.value = snapshot.docs
          .map((doc) => RoutePlanModel.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
      
      // Get active route plan
      if (routePlans.isNotEmpty) {
        RoutePlanModel? activeRoutePlan = routePlans.firstWhereOrNull((plan) => plan.isActive);
        if (activeRoutePlan != null) {
          currentRoutePlan.value = activeRoutePlan;
        }
      }
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error fetching route plans');
      print('Error fetching route plans: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<RoutePlanModel?> generateRoutePlan({
    required String name,
    required List<PlaceModel> places,
  }) async {
    if (!_authController.isLoggedIn) {
      UIHelpers.showErrorSnackBar('Please login to generate route');
      return null;
    }
    
    if (places.isEmpty) {
      UIHelpers.showErrorSnackBar('Please add places to your wishlist first');
      return null;
    }
    
    try {
      isGeneratingRoute.value = true;
      generationStatus.value = 'Analyzing your wishlist...';
      
      // Get AI recommendations for route
      generationStatus.value = 'Getting AI recommendations...';
      String aiRecommendation = await _aiService.getRoutePlanRecommendation(places);
      
      // Get map directions
      generationStatus.value = 'Calculating optimal route...';
      List<Map<String, dynamic>> directionsData = await _mapService.getOptimalRoute(places);
      
      // Create route steps
      List<RouteStepModel> steps = [];
      double totalDistanceKm = 0;
      int totalTimeMinutes = 0;
      
      for (int i = 0; i < directionsData.length; i++) {
        Map<String, dynamic> directionInfo = directionsData[i];
        PlaceModel place = places[i];
        
        RouteStepModel step = RouteStepModel(
          order: i + 1,
          place: place,
          travelMode: directionInfo['travelMode'] ?? 'driving',
          estimatedTimeMinutes: directionInfo['duration'] ?? 0,
          distanceKm: directionInfo['distance'] ?? 0,
          directionsInfo: directionInfo,
        );
        
        steps.add(step);
        totalDistanceKm += step.distanceKm;
        totalTimeMinutes += step.estimatedTimeMinutes;
      }
      
      // Create route plan model
      RoutePlanModel routePlan = RoutePlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _authController.firebaseUser.value!.uid,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        steps: steps,
        totalTimeMinutes: totalTimeMinutes,
        totalDistanceKm: totalDistanceKm,
        aiRecommendation: aiRecommendation,
        isActive: true,
      );
      
      // Save to Firestore
      generationStatus.value = 'Saving your route plan...';
      DocumentReference docRef = await _firestore
          .collection(AppConstants.routePlansCollection)
          .add(routePlan.toMap());
      
      // Deactivate other route plans
      if (currentRoutePlan.value != null) {
        await _firestore
            .collection(AppConstants.routePlansCollection)
            .doc(currentRoutePlan.value!.id)
            .update({'isActive': false});
      }
      
      // Update current route plan
      RoutePlanModel savedRoutePlan = routePlan.copyWith(id: docRef.id);
      routePlans.insert(0, savedRoutePlan);
      currentRoutePlan.value = savedRoutePlan;
      
      UIHelpers.showSuccessSnackBar('Route plan generated successfully');
      return savedRoutePlan;
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error generating route plan');
      print('Error generating route plan: $e');
      return null;
    } finally {
      isGeneratingRoute.value = false;
      generationStatus.value = '';
    }
  }
  
  Future<void> setActiveRoutePlan(String routePlanId) async {
    if (!_authController.isLoggedIn) return;
    
    try {
      isLoading.value = true;
      
      // Deactivate current route plan
      if (currentRoutePlan.value != null) {
        await _firestore
            .collection(AppConstants.routePlansCollection)
            .doc(currentRoutePlan.value!.id)
            .update({'isActive': false});
      }
      
      // Activate new route plan
      await _firestore
          .collection(AppConstants.routePlansCollection)
          .doc(routePlanId)
          .update({'isActive': true});
      
      // Update local state
      RoutePlanModel? newActivePlan = routePlans.firstWhereOrNull((plan) => plan.id == routePlanId);
      if (newActivePlan != null) {
        int index = routePlans.indexWhere((plan) => plan.id == routePlanId);
        routePlans[index] = newActivePlan.copyWith(isActive: true);
        currentRoutePlan.value = routePlans[index];
      }
      
      await fetchRoutePlans();
      UIHelpers.showSuccessSnackBar('Route plan activated');
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error activating route plan');
      print('Error activating route plan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteRoutePlan(String routePlanId) async {
    if (!_authController.isLoggedIn) return;
    
    try {
      isLoading.value = true;
      
      await _firestore
          .collection(AppConstants.routePlansCollection)
          .doc(routePlanId)
          .delete();
      
      routePlans.removeWhere((plan) => plan.id == routePlanId);
      
      if (currentRoutePlan.value?.id == routePlanId) {
        currentRoutePlan.value = null;
      }
      
      UIHelpers.showSuccessSnackBar('Route plan deleted');
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error deleting route plan');
      print('Error deleting route plan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateVisitStatus(String routePlanId, String placeId, bool isVisited) async {
    if (!_authController.isLoggedIn) return;
    
    try {
      // Get the route plan
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.routePlansCollection)
          .doc(routePlanId)
          .get();
      
      if (!doc.exists) return;
      
      RoutePlanModel routePlan = RoutePlanModel.fromMap(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
      
      // Find and update the step
      List<RouteStepModel> updatedSteps = routePlan.steps.map((step) {
        if (step.place.id == placeId) {
          return RouteStepModel(
            order: step.order,
            place: step.place.copyWith(isVisited: isVisited),
            travelMode: step.travelMode,
            estimatedTimeMinutes: step.estimatedTimeMinutes,
            distanceKm: step.distanceKm,
            directionsInfo: step.directionsInfo,
          );
        }
        return step;
      }).toList();
      
      // Update Firestore document
      await _firestore
          .collection(AppConstants.routePlansCollection)
          .doc(routePlanId)
          .update({
        'steps': updatedSteps.map((step) => step.toMap()).toList(),
        'updatedAt': DateTime.now(),
      });
      
      // Update local state
      int planIndex = routePlans.indexWhere((plan) => plan.id == routePlanId);
      if (planIndex != -1) {
        routePlans[planIndex] = routePlan.copyWith(steps: updatedSteps);
        
        if (currentRoutePlan.value?.id == routePlanId) {
          currentRoutePlan.value = routePlans[planIndex];
        }
      }
      
      // Also mark place as visited in the wishlist if needed
      if (isVisited) {
        PlaceModel? place = _placeController.wishlistPlaces.firstWhereOrNull((p) => p.id == placeId);
        if (place != null) {
          await _placeController.markPlaceAsVisited(place);
        }
      }
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error updating visit status');
      print('Error updating visit status: $e');
    }
  }
}
