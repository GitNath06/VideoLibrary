import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/subject_model.dart';
import '../services/api_service.dart';

class SubjectController extends GetxController {
  var subjectList = <ClassSubject>[].obs;
  var isLoading = false.obs;
  var isConnected = true.obs;
  var fetchAttempted = false.obs;

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
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    _updateConnectionStatus(result);
    if (isConnected.value) {
      await loadSubjects();
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _updateConnectionStatus(result);

      if (isConnected.value && (!fetchAttempted.value || subjectList.isEmpty)) {
        loadSubjects();
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

  late int _classId;

  void setClassId(int id) {
    _classId = id;
  }

  Future<void> loadSubjects() async {
    if (!isConnected.value) {
      print(" No internet, skipping fetch.");
      return;
    }

    try {
      isLoading.value = true;
      fetchAttempted.value = true;

      final subjects = await ApiServices.fetchSubjectsByClass(_classId);
      subjectList.assignAll(subjects);
    } catch (e) {
      print(" Error fetching subjects: $e");
      subjectList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
