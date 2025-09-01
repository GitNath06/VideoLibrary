import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';

class ChapterVideoController extends GetxController {
  var videoList = <ChapterVideo>[].obs;
  var isLoading = false.obs;
  var isConnected = true.obs;
  var fetchAttempted = false.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late int _chapterId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null && args['chapterId'] != null) {
      _chapterId = args['chapterId'] as int;
      print("Init with chapterId: $_chapterId");
    }

    _initializeConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initializeConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final res = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(res);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final r = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(r);

      if (isConnected.value && (!fetchAttempted.value || videoList.isEmpty)) {
        loadVideos(_chapterId);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;
    if (connected != isConnected.value) {
      isConnected.value = connected;
      print(connected ? 'Connected' : 'No Internet');
    }
  }

  Future<void> loadVideos(int chapterId) async {
    _chapterId = chapterId;

    if (!isConnected.value) {
      fetchAttempted.value = true;
      return;
    }

    try {
      isLoading.value = true;
      fetchAttempted.value = true;

      videoList.clear();
      final videos = await ApiServices.fetchVideosByChapter(chapterId);
      videoList.assignAll(videos);
    } catch (e) {
      print("Error loading videos: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
