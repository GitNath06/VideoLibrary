import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mero_vidya_library/extension/extension.dart';
import '../controllers/class_controller.dart';
import '../models/class_model.dart';
import 'subject_list_screen.dart';

class ClassListScreen extends StatelessWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClassController classController = Get.put(
      ClassController(),
      permanent: true,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 247),
        elevation: 10,
        centerTitle: true,
        title: const Text(
          "Mero Vidya Library",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 252, 252),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: () async {
          await classController.loadClasses();
          _showRefreshSnackbar(classController);
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
                      if (!classController.isConnected.value)
                        _noInternetBanner(),
                      _buildMainContent(context, classController),
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
      padding: const EdgeInsets.all(12),
      child: const Text(
        "No Internet Connection",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ClassController classController,
  ) {
    if (classController.isConnected.value && classController.isLoading.value) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (classController.isConnected.value &&
        classController.classList.isEmpty &&
        classController.fetchAttempted.value) {
      return _messageWidget(context, "No classes found. Pull down to refresh.");
    }

    if (!classController.isConnected.value &&
        classController.classList.isEmpty) {
      return _messageWidget(
        context,
        "Connect to the internet to load classes. Pull down to refresh.",
      );
    }

    return _buildClassGrid(context, classController);
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

  Widget _buildClassGrid(
    BuildContext context,
    ClassController classController,
  ) {
    final List<SchoolClass> classes = classController.classList;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height:
            (classes.length / 3).ceil() *
            (MediaQuery.of(context).size.width / 3 * 1.1 + 20),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          itemCount: classes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final currentClass = classes[index];
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (classController.isConnected.value) {
                    Get.to(
                      () => SubjectListScreen(
                        classId: currentClass.classId,
                        className: currentClass.className,
                      ),
                    );
                  } else {
                    Get.snackbar(
                      'Offline',
                      'Please connect to the internet to view subjects.',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                },
                splashColor: const Color.fromARGB(255, 164, 164, 180),
                highlightColor: const Color.fromARGB(255, 164, 164, 180),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(108, 106, 123, 255),
                        blurRadius: 3,
                        offset: Offset(2, 2),
                      ),
                      BoxShadow(color: Colors.white, offset: Offset(-2, -2)),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    currentClass.className,
                    style: TextStyle(
                      fontSize: 0.0125.toResponsive(context),
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 80, 76, 76),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRefreshSnackbar(ClassController classController) {
    if (classController.isConnected.value &&
        classController.classList.isNotEmpty) {
      Get.snackbar(
        'Refreshed',
        'Class list updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 47, 218, 53),
        colorText: Colors.white,
      );
    } else if (!classController.isConnected.value) {
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
        'No classes found after refresh. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
