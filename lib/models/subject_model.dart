class ClassSubject {
  final int subjectId;
  final String subjectName;
  final int classRef;

  ClassSubject({
    required this.subjectId,
    required this.subjectName,
    required this.classRef,
  });

  factory ClassSubject.fromJson(Map<String, dynamic> json) {
    return ClassSubject(
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
      classRef: json['class_ref'],
    );
  }
}
