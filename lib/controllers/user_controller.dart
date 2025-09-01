import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mero_vidya_library/widget/reusable_widget.dart';
import '../services/api_service.dart';
import '../screens/class_list_screen.dart';

class UserController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var loggedInUser = "".obs;

  // Login method
  Future<void> loginUser(String phone, String password) async {
    if (phone.isEmpty || password.isEmpty) {
      errorMessage.value = "Please enter all fields";
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await ApiServices.login(phone, password);

      if (response.containsKey("message") &&
          response["message"] == "Login successful") {
        loggedInUser.value = response["user"];
        // Show success snackbar
        CustomWidget.showSnackbar(
          title: "Success",
          message: "Logged in as ${loggedInUser.value}",
          icon: Icons.check_circle,
        );
        Get.offAll(() => const ClassListScreen());
      } else if (response.containsKey("error")) {
        errorMessage.value = response["error"];
      } else {
        errorMessage.value = "Unexpected error occurred";
      }
    } catch (e) {
      errorMessage.value = "Failed to connect to server";
    } finally {
      isLoading.value = false;
    }
  }

  // Signup method
  Future<void> signupUser(
    String phone,
    String password,
    String confirmPassword,
  ) async {
    if (phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorMessage.value = "Please enter all fields";
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await ApiServices.signup(
        phone,
        password,
        confirmPassword,
      );

      if (response.containsKey("message") &&
          response["message"] == "User registered successfully") {
        Get.snackbar("Success", "Signup successful, please login");
      } else if (response.containsKey("password") ||
          response.containsKey("confirm_password")) {
        errorMessage.value = "Passwords do not match";
      } else {
        errorMessage.value = response.toString();
      }
    } catch (e) {
      errorMessage.value = "Failed to connect to server";
    } finally {
      isLoading.value = false;
    }
  }
}
