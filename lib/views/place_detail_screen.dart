import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/place_model.dart';
import '../controllers/place_controller.dart';
import '../controllers/chat_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'chat_assistant_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;
  final PlaceController _placeController = Get.find<PlaceController>();
  final ChatController _chatController = Get.find<ChatController>();

  PlaceDetailScreen({required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaceHeader(),
                  SizedBox(height: 20),
                  _buildDescription(),
                  SizedBox(height: 20),
                  _buildInfoSection(),
                  SizedBox(height: 20),
                  _buildActionButtons(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
          final isInWishlist = _placeController.isInWishlist(place.id);
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(
          "assets/images/islamabad.jpg",
          fit: BoxFit.cover,
        ),
      ),
      actions: [

           IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.white,
            ),
            onPressed: () {
              if (isInWishlist) {
                _placeController.removeFromWishlist(place);
              } else {
                _placeController.addToWishlist(place);
              }
            },
          ),

      ],
    );
  }

  Widget _buildPlaceHeader() {
    final isVisited = place.isVisited;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                place.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  place.rating.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: place.categories.map((category) {
            return Chip(
              label: Text(
                category,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
        SizedBox(height: 8),

           isVisited
              ? Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Visited',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
              : SizedBox.shrink(),

      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          place.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    double latitude = place.location.latitude;
    double longitude = place.location.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildInfoItem(
          icon: Icons.location_on,
          title: 'Location',
          subtitle: 'Lat: $latitude, Long: $longitude',
        ),
        _buildInfoItem(
          icon: Icons.access_time,
          title: 'Best Time to Visit',
          subtitle: place.additionalInfo['bestTimeToVisit'] ?? 'All year',
        ),
        _buildInfoItem(
          icon: Icons.currency_rupee,
          title: 'Entrance Fee',
          subtitle: place.additionalInfo['entranceFee'] ?? 'Free',
        ),
        // Add more info items as needed
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
            final isInWishlist = _placeController.isInWishlist(place.id);
            final isVisited = place.isVisited;

      return Column(
        children: [

             CustomButton(
              text: isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
              onPressed: () {
                if (isInWishlist) {
                  _placeController.removeFromWishlist(place);
                } else {
                  _placeController.addToWishlist(place);
                }
              },
              color: isInWishlist ? Colors.red : AppColors.primaryColor,
              icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
            ),

          SizedBox(height: 12),

             CustomButton(
              text: isVisited ? 'Unmark as Visited' : 'Mark as Visited',
              onPressed: () {
                if (!isVisited) {
                  _placeController.markPlaceAsVisited(place);
                }
                // Unmark functionality would be added here
              },
              color: isVisited ? Colors.grey : Colors.green,
              icon: isVisited ? Icons.close : Icons.check,
            ),
          SizedBox(height: 12),
          CustomButton(
            text: 'Ask Assistant About This Place',
            onPressed: () {
              _chatController.sendMessage(
                  'Tell me about ${place.name} in Pakistan');
              Get.to(() => ChatAssistantScreen());
            },
            color: Colors.blue,
            icon: Icons.chat,
          ),
        ],
      );

  }
}
