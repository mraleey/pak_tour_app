import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/place_model.dart';
import '../models/route_plan_model.dart';
import '../app_constants.dart';
import '../models/wishlist_model.dart';
import '../utils/ui_helpers.dart';
import 'auth_controller.dart';

class PlaceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  RxList<PlaceModel> allPlaces = <PlaceModel>[].obs;
  RxList<PlaceModel> wishlistPlaces = <PlaceModel>[].obs;
  Rx<RoutePlanModel?> currentRoutePlan = Rx<RoutePlanModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isWishlistLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllPlaces();
    ever(_authController.firebaseUser, (_) {
      if (_authController.isLoggedIn) {
      } else {
        wishlistPlaces.clear();
        currentRoutePlan.value = null;
      }
    });
  }

  Future<void> fetchAllPlaces() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await _firestore.collection(AppConstants.placesCollection).get();

      allPlaces.value = snapshot.docs
          .map((doc) => PlaceModel.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error fetching places');
      print('Error fetching places: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToWishlist(PlaceModel place) async {
    if (!_authController.isLoggedIn) {
      UIHelpers.showErrorSnackBar('Please login to add to wishlist');
      return;
    }

    try {
      isWishlistLoading.value = true;

      if (wishlistPlaces.any((p) => p.id == place.id)) {
        UIHelpers.showInfoSnackBar('Place already in wishlist');
        return;
      }

      if (wishlistPlaces.length >= AppConstants.maxWishlistItems) {
        UIHelpers.showErrorSnackBar(
            'Wishlist is full. Remove some places to add more.');
        return;
      }

      DocumentReference wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_authController.firebaseUser.value!.uid);

      await wishlistRef.update({
        'places': FieldValue.arrayUnion([place.toMap()]),
        'updatedAt': DateTime.now(),
      });

      wishlistPlaces.add(place);
      Get.back();
      UIHelpers.showSuccessSnackBar('Added to wishlist');
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error adding to wishlist');
      print('Error adding to wishlist: $e');
    } finally {
      isWishlistLoading.value = false;
    }
  }

  Future<void> removeFromWishlist(PlaceModel place) async {
    if (!_authController.isLoggedIn) return;

    try {
      isWishlistLoading.value = true;

      DocumentReference wishlistRef = _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(_authController.firebaseUser.value!.uid);

      await wishlistRef.update({
        'places': FieldValue.arrayRemove([place.toMap()]),
        'updatedAt': DateTime.now(),
      });

      wishlistPlaces.removeWhere((p) => p.id == place.id);
      Get.back();
      UIHelpers.showSuccessSnackBar('Removed from wishlist');
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error removing from wishlist');
      print('Error removing from wishlist: $e');
    } finally {
      isWishlistLoading.value = false;
    }
  }

  Future<void> markPlaceAsVisited(PlaceModel place) async {
    if (!_authController.isLoggedIn) return;

    try {
      await _firestore.collection(AppConstants.visitsCollection).add({
        'userId': _authController.firebaseUser.value!.uid,
        'placeId': place.id,
        'visitDate': DateTime.now(),
        'notes': '',
      });

      // Update local list
      int index = wishlistPlaces.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        wishlistPlaces[index] = wishlistPlaces[index].copyWith(isVisited: true);

        // Update wishlist in Firestore
        final wishlistRef = _firestore
            .collection(AppConstants.wishlistsCollection)
            .doc(_authController.firebaseUser.value!.uid);

        final doc = await wishlistRef.get();
        if (doc.exists) {
          List<dynamic> places = (doc.data() as Map<String, dynamic>)['places'];
          int placeIndex = places.indexWhere((p) => p['id'] == place.id);
          if (placeIndex != -1) {
            places[placeIndex]['isVisited'] = true;
            await wishlistRef.update({
              'places': places,
              'updatedAt': DateTime.now(),
            });
          }
        }
      }

      // Update route plan
      if (currentRoutePlan.value != null) {
        final updatedSteps = currentRoutePlan.value!.steps.map((step) {
          if (step.place.id == place.id) {
            return RouteStepModel(
              order: step.order,
              place: step.place.copyWith(isVisited: true),
              travelMode: step.travelMode,
              estimatedTimeMinutes: step.estimatedTimeMinutes,
              distanceKm: step.distanceKm,
              directionsInfo: step.directionsInfo,
            );
          }
          return step;
        }).toList();

        final updatedPlan =
            currentRoutePlan.value!.copyWith(steps: updatedSteps);

        await _firestore
            .collection(AppConstants.routePlansCollection)
            .doc(updatedPlan.id)
            .update(updatedPlan.toMap());

        currentRoutePlan.value = updatedPlan;

        int remaining = updatedPlan.remainingPlaces.length;
        if (remaining == 0) {
          UIHelpers.showSuccessSnackBar(
              '🎉 You have visited all places in your route!');
        } else {
          UIHelpers.showSuccessSnackBar(
              'Marked ${place.name} as visited. $remaining places left.');
        }
      }
    } catch (e) {
      UIHelpers.showErrorSnackBar('Error marking place as visited');
      print('Error marking place as visited: $e');
    }
  }

  bool isInWishlist(String placeId) {
    return wishlistPlaces.any((place) => place.id == placeId);
  }
}
