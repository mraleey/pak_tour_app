import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';

class UIHelpers {
  static void showSnackBar(String message, {bool isError = false, bool isSuccess = false, bool isInfo = false}) {
    Color backgroundColor;
    IconData icon;
    
    if (isError) {
      backgroundColor = AppColors.errorColor;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = AppColors.successColor;
      icon = Icons.check_circle_outline;
    } else if (isInfo) {
      backgroundColor = AppColors.infoColor;
      icon = Icons.info_outline;
    } else {
      backgroundColor = AppColors.primaryColor;
      icon = Icons.notifications_none;
    }
    
    Get.snackbar(
      '',
      '',
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      borderRadius: 8,
      duration: Duration(seconds: 3),
    );
  }
  
  static void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }
  
  static void showSuccessSnackBar(String message) {
    showSnackBar(message, isSuccess: true);
  }
  
  static void showInfoSnackBar(String message) {
    showSnackBar(message, isInfo: true);
  }
  
  static void showLoadingDialog({String message = 'Loading...'}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  static void hideLoadingDialog() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }
  
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? AppColors.errorColor : AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 600;
  }
  
  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 900;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= 900;
  }
  
  static double paddingSmall(BuildContext context) {
    return isSmallScreen(context) ? 8 : 16;
  }
  
  static double paddingMedium(BuildContext context) {
    return isSmallScreen(context) ? 16 : 24;
  }
  
  static double paddingLarge(BuildContext context) {
    return isSmallScreen(context) ? 24 : 32;
  }
  
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes > 0 ? '${remainingMinutes}m' : ''}';
    }
  }
  
  static String formatDistance(double kilometers) {
    if (kilometers < 1) {
      return '${(kilometers * 1000).toStringAsFixed(0)} m';
    } else {
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }
  
  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
