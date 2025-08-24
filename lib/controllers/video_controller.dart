import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';

class ChapterVideoController extends GetxController {
  // =============================
  // 🔹 Existing State Variables
  // =============================
  var videoList =
      <ChapterVideo>[].obs; // List of videos for the current chapter
  var isLoading = false.obs; // Loading state for API calls
  var isConnected = true.obs; // Tracks internet connectivity
  var fetchAttempted = false.obs; // Ensures we don’t refetch unnecessarily

  // =============================
  // 🔹 NEW: Video Progress Storage
  // =============================
  var videoProgress = <int, double>{}.obs;
  // Stores watch progress for each video
  // Example: { 101: 0.65 } → videoId 101 watched 65%

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late int _chapterId;

  // (TODO: When backend is ready, replace with actual logged-in user ID)
  final int _userId = 123;

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

  // =============================
  // Connectivity Setup
  // =============================
  void _initializeConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final r = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(r);

    if (isConnected.value) loadVideos(_chapterId);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final nr = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(nr);
      if (isConnected.value && (!fetchAttempted.value || videoList.isEmpty)) {
        loadVideos(_chapterId);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;
    if (connected != isConnected.value) {
      isConnected.value = connected;
      print(connected ? ' Connected' : ' No Internet');
    }
  }

  // =============================
  // Load Videos + Progress
  // =============================
  Future<void> loadVideos(int chapterId) async {
    _chapterId = chapterId;
    if (!isConnected.value) {
      fetchAttempted.value = true;
      return;
    }
    try {
      isLoading.value = true;
      fetchAttempted.value = true;

      // 1. Fetch videos for this chapter
      final videos = await ApiServices.fetchVideosByChapter(chapterId);
      videoList.assignAll(videos);

      // 2. (NEW) Fetch saved progress from API
      try {
        final progressData = await ApiServices.fetchVideoProgress(
          _userId,
          chapterId,
        );

        // Merge progress data into map
        for (var entry in progressData.entries) {
          videoProgress[entry.key] =
              entry.value; // entry.key = videoId, entry.value = percentage
        }
      } catch (e) {
        print("No progress data available: $e");
      }

      // 3. (NEW) Initialize missing videos with 0% watched
      // for (var video in videos) {
      //   videoProgress.putIfAbsent(video.id, () => 0.0);
      // }
    } catch (e) {
      print("Error fetching videos or progress: $e");
      videoList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // =============================
  // (NEW) Update Progress
  // =============================
  // Future<void> updateProgress(int videoId, double progress) async {
  //   // Ensure value is between 0.0 and 1.0
  //   final safeProgress = progress.clamp(0.0, 1.0);

  //   // Update local state
  //   videoProgress[videoId] = safeProgress;

  //   print(
  //     "Video $videoId progress updated: ${(safeProgress * 100).toStringAsFixed(1)}%",
  //   );

  //   // Save to API (will work once backend supports it)
  //   try {
  //     await ApiServices.saveVideoProgress(_userId, videoId, safeProgress);
  //   } catch (e) {
  //     print("Error saving progress: $e");
  //   }
  // }

  // =============================
  // (NEW) Get Progress for a Video
  // =============================
  double getProgress(int videoId) {
    return videoProgress[videoId] ?? 0.0;
  }
}
