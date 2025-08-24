import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';

class ClassController extends GetxController {
  final RxList<SchoolClass> classList = <SchoolClass>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnected = true.obs;
  final RxBool fetchAttempted = false.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initializeConnectivity() async {
    // Initial connectivity check
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    _updateConnectionStatus(result);

    if (isConnected.value) {
      await loadClasses();
    }

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _updateConnectionStatus(result);

      if (isConnected.value && (!fetchAttempted.value || classList.isEmpty)) {
        loadClasses();
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;
    if (connected != isConnected.value) {
      isConnected.value = connected;
      print(connected ? 'Connected' : ' No Internet');
    }
  }

  Future<void> loadClasses() async {
    if (!isConnected.value) {
      print(" No internet, Fetching skipped.");
      return;
    }

    try {
      isLoading.value = true;
      fetchAttempted.value = true;

      final classes = await ApiServices.fetchClasses();
      classList.assignAll(classes);
    } catch (e) {
      print(" Error fetching classes: $e");
      classList.clear(); // Clear on error
    } finally {
      isLoading.value = false;
    }
  }
}
