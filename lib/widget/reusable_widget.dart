import "package:flutter/material.dart";
import "package:get/get.dart";

class CustomWidget {
  // Internet banner
  static Widget noInternetBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Color.fromRGBO(213, 0, 0, 1)),
          SizedBox(width: 8),
          Text(
            "No Internet Connection",
            style: TextStyle(
              color: Color.fromRGBO(213, 0, 0, 1),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Message widget
  static Widget messageWidget(BuildContext context, String message) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ======================
  // Snackbar Function
  // ======================

  static void showSnackbar({
    required String title,
    String message = '',
    required IconData icon,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 1),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14, // smaller font
            ),
          ),
        ],
      ),
      messageText: message.isNotEmpty
          ? Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12, // smaller font
              ),
            )
          : null,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.all(15),
      borderRadius: 8,
      duration: const Duration(seconds: 1),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ), // 👈 reduce vertical padding
      isDismissible: true,
    );
  }
}








// Get.snackbar(
//           "Success",
//           "Logged in as ${loggedInUser.value}",
//           snackPosition: SnackPosition.BOTTOM, // show at the bottom
//           backgroundColor: const Color.fromARGB(255, 1, 26, 255),
//           colorText: const Color.fromARGB(255, 98, 98, 98),
//           borderRadius: 12,
//           margin: const EdgeInsets.all(10),
//           icon: const Icon(Icons.check_circle, color: Colors.white),
//           shouldIconPulse: true,
//           duration: const Duration(seconds: 2),
//           isDismissible: true,
//           forwardAnimationCurve: Curves.easeOutBack,
//         );