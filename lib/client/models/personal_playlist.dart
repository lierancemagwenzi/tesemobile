class PersonalPlaylist {
  final int id;
  final int userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;

  PersonalPlaylist({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  factory PersonalPlaylist.fromJson(Map<String, dynamic> json) {
    return PersonalPlaylist(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      // Parsing the date strings from your Sequelize response
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      itemCount: json['item_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'item_count': itemCount,
    };
  }
}
