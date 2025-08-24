import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/video_controller.dart';

// App-wide color constants
const kProgressIndicatorColor = Colors.red;

/// Screen that displays a list of YouTube videos for a given chapter.
/// Uses GetX for state management.
class ChapterVideoListScreen extends StatelessWidget {
  final int chapterId; // ID of the chapter
  final String chapterName; // Name of the chapter (for AppBar title)

  // Controller (GetX)
  final ChapterVideoController ctrl = Get.put(ChapterVideoController());

  ChapterVideoListScreen({
    required this.chapterId,
    required this.chapterName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deviceOrientation = MediaQuery.of(context).orientation;

    // Make sure videos load at least once when the widget is built
    Future.microtask(() => ctrl.loadVideos(chapterId));

    return Scaffold(
      // Show AppBar only in portrait mode
      appBar: deviceOrientation == Orientation.portrait
          ? AppBar(
              title: Text('Videos: $chapterName'),
              backgroundColor: const Color.fromARGB(255, 4, 0, 247),
              foregroundColor: Colors.white,
              centerTitle: true,
            )
          : null,

      backgroundColor: Colors.grey[100],

      // Pull-to-refresh functionality
      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: () => ctrl.loadVideos(chapterId),

        // Layout builder to handle screen constraints
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                // Reactive UI: automatically updates when controller state changes
                child: Obx(() {
                  return Column(
                    children: [
                      /// 🔴 No Internet Banner
                      if (!ctrl.isConnected.value)
                        Container(
                          width: double.infinity,
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: const Text(
                            'No Internet Connection',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      /// ⏳ Loading Indicator
                      if (ctrl.isLoading.value)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      /// 📭 Empty State (No videos after fetch attempt)
                      else if (ctrl.videoList.isEmpty &&
                          ctrl.fetchAttempted.value)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text('No videos available.'),
                          ),
                        )
                      /// 🌐 User is offline and no cached videos
                      else if (!ctrl.isConnected.value &&
                          ctrl.videoList.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text(
                              'Connect to the internet to load videos.',
                            ),
                          ),
                        )
                      /// ✅ Show video list
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ctrl.videoList.length,
                          itemBuilder: (ctx, i) {
                            final video = ctrl.videoList[i];

                            // Extract YouTube video ID from URL
                            final vid = YoutubePlayer.convertUrlToId(
                              video.videoLink,
                            );
                            if (vid == null) return const SizedBox.shrink();

                            // Create YouTube player controller
                            final ytCtrl = YoutubePlayerController(
                              initialVideoId: vid,
                              flags: const YoutubePlayerFlags(autoPlay: false),
                            );

                            // Build the YouTube player with title
                            return YoutubePlayerBuilder(
                              player: YoutubePlayer(
                                controller: ytCtrl,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: kProgressIndicatorColor,
                              ),
                              builder: (context, player) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  player, // Video Player
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      video.videoTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
}
