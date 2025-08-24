import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mero_vidya_library/extension/extension.dart';
import '../controllers/chapter_controller.dart';
import 'package:mero_vidya_library/screens/video_list_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final int subjectId;
  final String subjectName;

  ChapterListScreen({
    required this.subjectId,
    required this.subjectName,
    super.key,
  });

  final SubjectChapterController ctrl = Get.put(SubjectChapterController());

  @override
  Widget build(BuildContext context) {
    ctrl.loadChapters(subjectId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 0, 247),
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Chapters: $subjectName',
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
          await ctrl.loadChapters(subjectId);
          _showRefreshSnackbar();
        },
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Obx(() {
                  return Column(
                    children: [
                      if (!ctrl.isConnected.value) _noInternetBanner(),
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

  Widget _buildMainContent(BuildContext context) {
    if (ctrl.isLoading.value) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (ctrl.chapterList.isEmpty && ctrl.fetchAttempted.value) {
      return _messageWidget(
        context,
        'No chapters available. Pull down to refresh.',
      );
    }

    if (!ctrl.isConnected.value && ctrl.chapterList.isEmpty) {
      return _messageWidget(
        context,
        'Connect to the internet to load chapters. Pull down to refresh.',
      );
    }

    return _chapterListView(context);
  }

  Widget _chapterListView(BuildContext context) {
    return SizedBox(
      width: 1.0.w(context),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: ctrl.chapterList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          final chapter = ctrl.chapterList[i];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade200],
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
                    () => ChapterVideoListScreen(
                      chapterId: chapter.chapterId,
                      chapterName: chapter.chapterName,
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
                    chapter.chapterName,
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
    if (ctrl.isConnected.value && ctrl.chapterList.isNotEmpty) {
      Get.snackbar(
        'Refreshed',
        'Chapters updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 47, 218, 53),
        colorText: Colors.white,
      );
    } else if (!ctrl.isConnected.value) {
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
        'No chapters found after refresh.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
