import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mero_vidya_library/extension/extension.dart';
import 'package:mero_vidya_library/screens/chapter_list_screen.dart';
import '../controllers/subject_controller.dart';
// import '../models/subject_model.dart';

class SubjectListScreen extends StatelessWidget {
  final int classId;
  final String className;

  SubjectListScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  final SubjectController subjectController = Get.put(SubjectController());

  @override
  Widget build(BuildContext context) {
    subjectController.setClassId(classId);
    subjectController.loadSubjects();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 0, 247),
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Subjects of $className',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: () async {
          await subjectController.loadSubjects();
          _showRefreshSnackbar();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Obx(() {
                  return Column(
                    children: [
                      if (!subjectController.isConnected.value)
                        _noInternetBanner(),
                      _buildMainContent(context),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔺 Red banner for no internet
  Widget _noInternetBanner() {
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        "No Internet Connection",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 📦 Message widget for empty or offline-with-no-data states
  Widget _messageWidget(BuildContext context, String message) {
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

  /// 📦 Builds loading, empty, or subject list based on state
  Widget _buildMainContent(BuildContext context) {
    if (subjectController.isLoading.value) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (subjectController.subjectList.isEmpty &&
        subjectController.fetchAttempted.value) {
      return _messageWidget(
        context,
        'No subjects available. Pull down to refresh.',
      );
    }

    if (!subjectController.isConnected.value &&
        subjectController.subjectList.isEmpty) {
      return _messageWidget(
        context,
        'Connect to the internet to load subjects. Pull down to refresh.',
      );
    }

    return _subjectListView(context);
  }

  Widget _subjectListView(BuildContext context) {
    return SizedBox(
      width: 1.0.w(context),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: subjectController.subjectList.length,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final subject = subjectController.subjectList[index];
          return Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
                const BoxShadow(color: Colors.white, offset: Offset(-2, -2)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  Get.to(
                    () => ChapterListScreen(
                      subjectId: subject.subjectId,
                      subjectName: subject.subjectName,
                    ),
                  );
                },
                splashColor: const Color.fromARGB(255, 164, 164, 180),
                highlightColor: const Color.fromARGB(255, 164, 164, 180),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 0.014.h(context),
                    horizontal: 0.05.w(context),
                  ),
                  child: Text(
                    subject.subjectName,
                    style: TextStyle(
                      fontSize: 0.0125.toResponsive(context),
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 80, 76, 76),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRefreshSnackbar() {
    if (subjectController.isConnected.value &&
        subjectController.subjectList.isNotEmpty) {
      Get.snackbar(
        'Refreshed',
        'Subjects updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 47, 218, 53),
        colorText: Colors.white,
      );
    } else if (!subjectController.isConnected.value) {
      Get.snackbar(
        'No Internet',
        'Cannot refresh without internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'No Data',
        'No subjects found after refresh.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
