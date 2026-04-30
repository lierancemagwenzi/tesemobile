class VideoStatsModel {
  final int likes;
  final int downloads;
  final int views;
  final int unique_views;
  final bool liked;

  final int monthly_earnings;
  final int monthly_sales;
  final int total_earnings;
  final int total_sales;

  VideoStatsModel({
    this.likes = 0,
    this.downloads = 0,
    this.views = 0,
    this.unique_views = 0,
    this.liked = false,
    this.total_earnings = 0,
    this.monthly_earnings = 0,
    this.monthly_sales = 0,
    this.total_sales = 0,
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
      total_earnings: json['total_earnings'] ?? 0,
      monthly_earnings: json['monthly_earnings'] ?? 0,
      monthly_sales: json['monthly_sales'] ?? 0,
      total_sales: json['total_sales'] ?? 0,
      unique_views: json['unique_views'] ?? 0,
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
