class ChapterVideo {
  final String videoTitle;
  final String videoLink; // YouTube video ID
  final int chapterRef;

  ChapterVideo({
    required this.videoTitle,
    required this.videoLink,
    required this.chapterRef,
  });

  factory ChapterVideo.fromJson(Map<String, dynamic> json) {
    return ChapterVideo(
      videoTitle: json['video_title'] ?? 'No Title',
      videoLink: json['video_link'] ?? '', // Correct YouTube ID
      chapterRef: json['chapter_ref'] ?? 0,
    );
  }
}
