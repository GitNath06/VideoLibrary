import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mero_vidya_library/models/chapter_model.dart';
import 'package:mero_vidya_library/widget/reusable_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/video_controller.dart';

// App-wide color constants
const kProgressIndicatorColor = Colors.red;

/// Screen that displays a list of YouTube videos for a given chapter.
/// Uses GetX for state management.
class ChapterVideoListScreen extends StatefulWidget {
  final int chapterId;
  final String chapterName;
  final List<SubjectChapter> chapterList;
  final int currentIndex;

  const ChapterVideoListScreen({
    required this.chapterId,
    required this.chapterName,
    required this.chapterList,
    required this.currentIndex,
    super.key,
  });

  @override
  State<ChapterVideoListScreen> createState() => _ChapterVideoListScreenState();
}

class _ChapterVideoListScreenState extends State<ChapterVideoListScreen> {
  // Name of the chapter (for AppBar title)
  late ChapterVideoController ctrl;
  late int currentChapterId;
  late String currentChapterName;
  late int currentIndex;
  late YoutubePlayerController ytCtrl;

  @override
  void initState() {
    super.initState();

    currentChapterId = widget.chapterId;
    currentChapterName = widget.chapterName;
    currentIndex = widget.currentIndex;

    // Load videos for the current chapter
    ctrl = Get.put(ChapterVideoController(), tag: '$currentChapterId');

    Future.microtask(() async {
      await ctrl.loadVideos(currentChapterId);

      if (ctrl.videoList.isNotEmpty) {
        final videoId = YoutubePlayer.convertUrlToId(
          ctrl.videoList[0].videoLink,
        );
        if (videoId != null) {
          ytCtrl = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: true),
          );
          setState(() {}); // Ensure widget rebuilds with the controller
        }
      }
    });
  }

  void loadChapter(int index) async {
    final nextChapter = widget.chapterList[index];
    final nextId = nextChapter.chapterId;

    // Clean up previous controller
    Get.delete<ChapterVideoController>(tag: '$currentChapterId');

    setState(() {
      currentChapterId = nextId;
      currentChapterName = nextChapter.chapterName;
      currentIndex = index;
    });

    // Load new chapter controller and videos
    ctrl = Get.put(ChapterVideoController(), tag: '$nextId');
    await ctrl.loadVideos(nextId);

    if (ctrl.videoList.isNotEmpty) {
      final newVideoId = YoutubePlayer.convertUrlToId(
        ctrl.videoList[0].videoLink,
      );
      if (newVideoId != null) {
        ytCtrl.load(newVideoId); // 🔁 Switches to the new video
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceOrientation = MediaQuery.of(context).orientation;

    // Make sure videos load at least once when the widget is built
    // Future.microtask(() => ctrl.loadVideos(widget.chapterId));

    return Scaffold(
      // Show AppBar only in portrait mode
      appBar: deviceOrientation == Orientation.portrait
          ? AppBar(
              // title: Text('Videos: ${widget.chapterName}'),
              title: Text('Videos'),

              backgroundColor: const Color.fromARGB(255, 4, 0, 247),
              foregroundColor: Colors.white,
              centerTitle: true,
            )
          : null,

      backgroundColor: Colors.grey[100],

      // Pull-to-refresh functionality
      body: RefreshIndicator(
        color: Colors.red,
        onRefresh: () => ctrl.loadVideos(widget.chapterId),

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
                      /// 🔴 No Internet
                      if (!ctrl.isConnected.value)
                        CustomWidget.noInternetBanner(),

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
                            print(
                              "🎥=========== Building video widget for: ${video.videoTitle}",
                            );

                            // Get youtube id from this item
                            final vid = YoutubePlayer.convertUrlToId(
                              video.videoLink,
                            );
                            if (vid == null) return const SizedBox.shrink();

                            // create a per-item controller (local name to avoid confusion with class ytCtrl)
                            final itemYtCtrl = YoutubePlayerController(
                              initialVideoId: vid,
                              flags: const YoutubePlayerFlags(autoPlay: false),
                            );

                            return YoutubePlayerBuilder(
                              player: YoutubePlayer(
                                key: ValueKey(itemYtCtrl.initialVideoId),
                                controller: itemYtCtrl,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: kProgressIndicatorColor,
                              ),
                              builder: (context, player) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  player,
                                  const SizedBox(height: 8),
                                  // show this video's title (not always ctrl.videoList[0])
                                  Text(
                                    video.videoTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      // ⏮️⏭️ Previous / Next Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            /// ⏮️ Previous
                            ElevatedButton(
                              onPressed: currentIndex > 0
                                  ? () {
                                      print(
                                        "=========================================== Previous button clicked !!! ============================================",
                                      );
                                      loadChapter(currentIndex - 1);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Icon(Icons.skip_previous),
                            ),

                            // ⏭️ Next
                            ElevatedButton(
                              onPressed:
                                  currentIndex < widget.chapterList.length - 1
                                  ? () {
                                      print(
                                        "=========================================== Next button clicked !!! ============================================",
                                      );
                                      loadChapter(currentIndex + 1);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Icon(Icons.skip_next),
                            ),
                          ],
                        ),
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
