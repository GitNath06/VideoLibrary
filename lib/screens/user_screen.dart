// lib/screens/user_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mero_vidya_library/widget/reusable_widget.dart';
import '../controllers/user_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============ Controllers ============
  final UserController userController = Get.put(UserController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ============ UI State ============
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final RxBool isLoginMode = true.obs;

  // ============ Connectivity (mirrors class_list_screen pattern) ============
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final RxBool fetchAttempted = false.obs;
  StreamSubscription<dynamic>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ---- Same style as your ClassController ----
  Future<void> _initializeConnectivity() async {
    // Initial connectivity check
    final result = await _coerceCheckConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes (handle both List<ConnectivityResult> and ConnectivityResult)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      dynamic results,
    ) {
      final ConnectivityResult result = _coerceStreamResult(results);
      _updateConnectionStatus(result);
    });
  }

  Future<ConnectivityResult> _coerceCheckConnectivity() async {
    final dynamic checked = await _connectivity.checkConnectivity();
    if (checked is List<ConnectivityResult>) {
      return checked.isNotEmpty ? checked.first : ConnectivityResult.none;
    } else if (checked is ConnectivityResult) {
      return checked;
    }
    return ConnectivityResult.none;
  }

  ConnectivityResult _coerceStreamResult(dynamic results) {
    if (results is List<ConnectivityResult>) {
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } else if (results is ConnectivityResult) {
      return results;
    }
    return ConnectivityResult.none;
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;
    if (connected != isConnected.value) {
      isConnected.value = connected;
      // Matches your style: just log; UI shows a banner/snackbar elsewhere
      // print(connected ? 'Connected' : ' No Internet');
    }
  }

  // Pull-to-refresh feedback (adapted for auth screen)
  void _showRefreshSnackbar() {
    if (isConnected.value) {
      Get.snackbar(
        'Online',
        'Internet connection restored!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 47, 218, 53),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'No Internet',
        'Still offline. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => Column(
          children: [
            // Main content with pull-to-refresh (exact pattern as your class screen)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  fetchAttempted.value = true;
                  final result = await _coerceCheckConnectivity();
                  _updateConnectionStatus(result);
                  _showRefreshSnackbar();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // School Logo
                      Center(
                        child: Image.asset(
                          "lib/assets/images/school_logo.png",
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // School Name
                      const Text(
                        "Shree Ratna Rajya Laxmi Secondary School",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Phone Field
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password (only in signup mode)
                      if (!isLoginMode.value)
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      if (!isLoginMode.value) const SizedBox(height: 30),

                      // Login/Signup Button
                      Obx(
                        () => userController.isLoading.value
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (!isConnected.value) {
                                      Get.snackbar(
                                        'No Internet',
                                        'Please connect to the internet to continue.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }

                                    if (isLoginMode.value) {
                                      userController.loginUser(
                                        phoneController.text.trim(),
                                        passwordController.text.trim(),
                                      );
                                    } else {
                                      userController.signupUser(
                                        phoneController.text.trim(),
                                        passwordController.text.trim(),
                                        confirmPasswordController.text.trim(),
                                      );
                                    }
                                  },
                                  child: Text(
                                    isLoginMode.value
                                        ? "Login as Student"
                                        : "Signup as Student",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      if (!isConnected.value) CustomWidget.noInternetBanner(),
                      const SizedBox(height: 20),

                      // Error message display
                      Obx(
                        () => userController.errorMessage.value.isNotEmpty
                            ? Text(
                                userController.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),

                      // Toggle between Login & Signup
                      TextButton(
                        onPressed: () {
                          isLoginMode.value = !isLoginMode.value;
                        },
                        child: Text(
                          isLoginMode.value
                              ? "Don’t have an account? Signup"
                              : "Already have an account? Login",
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Small hint line like your class screen copy uses
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
