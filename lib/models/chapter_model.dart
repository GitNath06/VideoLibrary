class SubjectChapter {
  final int chapterId;
  final String chapterName;
  final int subjectRef;

  SubjectChapter({
    required this.chapterId,
    required this.chapterName,
    required this.subjectRef,
  });

  factory SubjectChapter.fromJson(Map<String, dynamic> json) {
    return SubjectChapter(
      chapterId: json['chapter_id'],
      chapterName: json['chapter_name'],
      subjectRef: json['subject_ref'],
    );
  }
}
