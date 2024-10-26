class Task {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String priority;
  final List<Map<String, String>> participants; // Thêm participants

  Task({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.participants,
  });
}
