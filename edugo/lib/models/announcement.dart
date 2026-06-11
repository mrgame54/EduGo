class Announcement {
  final int id;
  final String title;
  final String body;
  final String priority;
  final DateTime createdAt;
  final int readCount;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    required this.readCount,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      priority: json['priority'] as String? ?? 'Normal',
      createdAt: DateTime.parse(json['created_at'] as String),
      readCount: json['read_count'] as int? ?? 0,
    );
  }
}
