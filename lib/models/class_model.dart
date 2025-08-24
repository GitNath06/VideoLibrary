class SchoolClass {
  final int classId;
  final String className;

  SchoolClass({required this.classId, required this.className});

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      classId: json['class_id'],
      className: json['class_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'class_id': classId, 'class_name': className};
  }
}
