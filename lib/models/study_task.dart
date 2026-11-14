class StudyTask {
  String title;
  String subject;
  DateTime deadline;
  bool isCompleted;

  StudyTask({
    required this.title,
    required this.subject,
    required this.deadline,
    this.isCompleted = false,
  });

  // Convert task into JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Convert JSON back into task
  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      title: json['title'] as String,
      subject: json['subject'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }
}