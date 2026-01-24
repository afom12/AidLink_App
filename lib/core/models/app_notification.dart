class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.deepLink,
    this.category,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? deepLink;
  final String? category;

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink,
      category: category,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt']?.toString();
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: rawDate != null
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
      deepLink: json['deepLink']?.toString(),
      category: json['category']?.toString(),
    );
  }
}

