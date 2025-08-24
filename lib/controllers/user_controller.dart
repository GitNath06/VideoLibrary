import 'package:get/get.dart';
import '../services/api_service.dart'; // ✅ Import ApiServices which contains dummy API methods

class UserController extends GetxController {
  // Observable variables for UI state
  var isLoading = false.obs; // Indicates whether an API call is in progress
  var errorMessage = ''.obs; // Stores error messages for UI display

  /// ================================
  /// User Registration
  /// ================================
  /// Currently uses dummy API from ApiServices for UI testing.
  /// Once backend is ready, replace this call with the real API endpoint.
  Future<void> registerUser(
    String username,
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true; // Start loading
      errorMessage.value = ''; // Clear previous errors

      // -----------------------------
      // Call dummy API method
      // -----------------------------
      final result = await ApiServices.registerUser(username, email, password);

      if (result['success'] == true) {
        // ✅ Registration succeeded
        Get.snackbar("Success", "User registered successfully!");
        print("🔑 Dummy Token: ${result['data']['token']}");
        // Later: save token or user data as needed
      } else {
        // ❌ Registration failed
        errorMessage.value = result['message'] ?? 'Registration failed';
        Get.snackbar("Error", errorMessage.value);
      }
    } catch (e) {
      // ❌ Exception occurred
      errorMessage.value = e.toString();
      Get.snackbar("Exception", errorMessage.value);
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  /// ================================
  /// User Login
  /// ================================
  /// Currently uses dummy API from ApiServices for UI testing.
  /// Once backend is ready, replace this call with the real API endpoint.
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true; // Start loading
      errorMessage.value = ''; // Clear previous errors

      // -----------------------------
      // Call dummy API method
      // -----------------------------
      final result = await ApiServices.loginUser(email, password);

      if (result['success'] == true) {
        // ✅ Login succeeded
        Get.snackbar("Success", "Login successful!");
        print("🔑 Dummy Token: ${result['data']['token']}");
        // Later: save token or user data in GetStorage or secure storage
      } else {
        // ❌ Login failed
        errorMessage.value = result['message'] ?? 'Login failed';
        Get.snackbar("Error", errorMessage.value);
      }
    } catch (e) {
      // ❌ Exception occurred
      errorMessage.value = e.toString();
      Get.snackbar("Exception", errorMessage.value);
    } finally {
      isLoading.value = false; // Stop loading
    }
  }
}
