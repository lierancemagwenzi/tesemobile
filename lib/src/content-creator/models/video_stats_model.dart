class VideoStatsModel {
  final int likes;
  final int downloads;
  final int views;
  final bool liked;

  VideoStatsModel({
    this.likes = 0,
    this.downloads = 0,
    this.views = 0,
    this.liked = false,
  });

  // Helper to update specific fields while keeping others the same
  VideoStatsModel copyWith({
    int? likes,
    int? downloads,
    int? views,
    bool? liked,
  }) {
    return VideoStatsModel(
      likes: likes ?? this.likes,
      downloads: downloads ?? this.downloads,
      views: views ?? this.views,
      liked: liked ?? this.liked,
    );
  }

  // To handle data from a database/API
  factory VideoStatsModel.fromJson(Map<String, dynamic> json) {
    return VideoStatsModel(
      likes: json['likes'] ?? 0,
      downloads: json['downloads'] ?? 0,
      views: json['views'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  // To send data back to a database/API
  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'downloads': downloads,
      'views': views,
      'liked': liked,
    };
  }
}
