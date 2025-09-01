import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/chapter_model.dart';
import '../services/api_service.dart';

class SubjectChapterController extends GetxController {
  var chapterList = <SubjectChapter>[].obs;
  var isLoading = false.obs;
  var isConnected = true.obs;
  var fetchAttempted = false.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late int _subjectId;

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
    final results = await _connectivity.checkConnectivity();
    final res = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(res);

    if (isConnected.value) loadChapters(_subjectId);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final r = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(r);

      if (isConnected.value && (!fetchAttempted.value || chapterList.isEmpty)) {
        loadChapters(_subjectId);
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

  Future<void> loadChapters(int subjectId) async {
    _subjectId = subjectId;

    if (!isConnected.value) {
      print("No internet, skipping fetch.");
      return;
    }

    try {
      isLoading.value = true;
      fetchAttempted.value = true;
      final chapters = await ApiServices.fetchChaptersBySubject(subjectId);
      chapterList.assignAll(chapters);
    } catch (e) {
      print("Error fetching chapters: $e");
      chapterList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
