class Grade {
  final int? id;
  final int studentId;
  final int classId;
  int attendance;
  int quizzes;
  int assignments;
  int exams;

  Grade({
    this.id,
    required this.studentId,
    required this.classId,
    this.attendance = 0,
    this.quizzes = 0,
    this.assignments = 0,
    this.exams = 0,
  });

  get name => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'attendance': attendance,
      'quizzes': quizzes,
      'assignments': assignments,
      'exams': exams,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      studentId: map['student_id'],
      classId: map['class_id'],
      attendance: map['attendance'],
      quizzes: map['quizzes'],
      assignments: map['assignments'],
      exams: map['exams'],
    );
  }
}