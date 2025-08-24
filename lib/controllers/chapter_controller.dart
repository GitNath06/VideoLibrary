import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/chapter_model.dart';
import '../services/api_service.dart';

/// Controller for managing subject chapters in GetX.
/// Handles API calls, internet connectivity, and state updates.
class SubjectChapterController extends GetxController {
  // Observable list of chapters (updates UI automatically when changed)
  var chapterList = <SubjectChapter>[].obs;

  // Observable flags for loading state, internet connection, and fetch attempt
  var isLoading = false.obs;
  var isConnected = true.obs;
  var fetchAttempted = false.obs;

  // Connectivity plugin instance
  final Connectivity _connectivity = Connectivity();

  // Subscription to listen for network changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Stores the current subject ID to fetch chapters for
  late int _subjectId;

  /// Called when the controller is first initialized.
  /// Sets up internet connectivity checks.
  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
  }

  /// Called when the controller is disposed.
  /// Cleans up connectivity subscription.
  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Initialize connectivity listener and load chapters if internet is available.
  void _initializeConnectivity() async {
    // Check current connectivity status
    final results = await _connectivity.checkConnectivity();
    final res = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(res);

    // If connected, load chapters for the stored subject
    if (isConnected.value) loadChapters(_subjectId);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final r = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(r);

      // If internet is available and chapters not yet fetched, fetch again
      if (isConnected.value && (!fetchAttempted.value || chapterList.isEmpty)) {
        loadChapters(_subjectId);
      }
    });
  }

  /// Update connection status based on connectivity result.
  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;

    // Only update if connection status has changed
    if (connected != isConnected.value) {
      isConnected.value = connected;
      print(connected ? '✅ Connected' : '⚠️ No Internet');
    }
  }

  /// Fetch chapters for a specific subject from API.
  Future<void> loadChapters(int subjectId) async {
    _subjectId = subjectId; // Save subject ID for retry use

    // Skip fetching if offline
    if (!isConnected.value) {
      print("⚠️ No internet, skipping fetch.");
      return;
    }

    try {
      // Show loading indicator
      isLoading.value = true;
      fetchAttempted.value = true;

      // Call API to fetch chapters
      final chapters = await ApiServices.fetchChaptersBySubject(subjectId);

      // Update observable chapter list
      chapterList.assignAll(chapters);
    } catch (e) {
      // Handle error case
      print("❌ Error fetching chapters: $e");
      chapterList.clear();
    } finally {
      // Hide loading indicator
      isLoading.value = false;
    }
  }
}
