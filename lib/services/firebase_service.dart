import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_constants.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../models/route_plan_model.dart';
import '../models/wishlist_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Auth methods
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;
  
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    }
  }
  
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e;
    }
  }
  
  // Firestore methods - Users
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
          
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
  
  Future<void> createUserData(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      print('Error creating user data: $e');
      throw e;
    }
  }
  
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }
  
  // Firestore methods - Places
  Future<List<PlaceModel>> getAllPlaces() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .get();
          
      return snapshot.docs
          .map((doc) => PlaceModel.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error fetching places: $e');
      throw e;
    }
  }
  
  Future<PlaceModel?> getPlaceById(String placeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.placesCollection)
          .doc(placeId)
          .get();
          
      if (doc.exists) {
        return PlaceModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching place: $e');
      return null;
    }
  }
  
  // Firestore methods - Wishlist
  Future<WishlistModel?> getUserWishlist(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .get();
          
      if (doc.exists) {
        return WishlistModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching wishlist: $e');
      return null;
    }
  }
  
  Future<void> createUserWishlist(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .set({
        'userId': userId,
        'places': [],
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error creating wishlist: $e');
      throw e;
    }
  }
  
  Future<void> addPlaceToWishlist(String userId, PlaceModel place) async {
    try {
      await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .update({
        'places': FieldValue.arrayUnion([place.toMap()]),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error adding place to wishlist: $e');
      throw e;
    }
  }
  
  Future<void> removePlaceFromWishlist(String userId, PlaceModel place) async {
    try {
      await _firestore
          .collection(AppConstants.wishlistsCollection)
          .doc(userId)
          .update({
        'places': FieldValue.arrayRemove([place.toMap()]),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error removing place from wishlist: $e');
      throw e;
    }
  }
  
  // Firestore methods - Route Plans
  Future<List<RoutePlanModel>> getUserRoutePlans(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.routePlansCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
          
      return snapshot.docs
          .map((doc) => RoutePlanModel.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error fetching route plans: $e');
      throw e;
    }
  }
  
  Future<DocumentReference> createRoutePlan(RoutePlanModel routePlan) async {
    try {
      return await _firestore
          .collection(AppConstants.routePlansCollection)
          .add(routePlan.toMap());
    } catch (e) {
      print('Error creating route plan: $e');
      throw e;
    }
  }
  
  Future<void> updateRoutePlan(String routePlanId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.routePlansCollection)
          .doc(routePlanId)
          .update(data);
    } catch (e) {
      print('Error updating route plan: $e');
      throw e;
    }
  }
  
  Future<void> deleteRoutePlan(String routePlanId) async {
    try {
      await _firestore
          .collection(AppConstants.routePlansCollection)
          .doc(routePlanId)
          .delete();
    } catch (e) {
      print('Error deleting route plan: $e');
      throw e;
    }
  }
  
  // Firestore methods - Chat messages
  Future<List<ChatMessage>> getUserChatMessages(String userId, {int limit = 50}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
          
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error fetching chat messages: $e');
      throw e;
    }
  }
  
  Future<DocumentReference> addChatMessage(ChatMessage message) async {
    try {
      return await _firestore
          .collection('chats')
          .add(message.toMap());
    } catch (e) {
      print('Error adding chat message: $e');
      throw e;
    }
  }
  
  Future<void> deleteAllUserChatMessages(String userId) async {
    try {
      // Get all messages for this user
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .where('userId', isEqualTo: userId)
          .get();
      
      // Delete in batches
      WriteBatch batch = _firestore.batch();
      snapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      
      await batch.commit();
    } catch (e) {
      print('Error deleting chat messages: $e');
      throw e;
    }
  }
  
  // Firestore methods - Visits
  Future<void> recordVisit(String userId, String placeId) async {
    try {
      await _firestore
          .collection(AppConstants.visitsCollection)
          .add({
        'userId': userId,
        'placeId': placeId,
        'visitDate': DateTime.now(),
        'notes': '',
      });
    } catch (e) {
      print('Error recording visit: $e');
      throw e;
    }
  }
}
