import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';

class ClientHomeDashboardModel {
  final List<Video> recentVideos;
  final List<User> popularCreators;
  final List<Video> trendingVideos;
  final List<Channel> featuredChannels;

  ClientHomeDashboardModel({
    this.recentVideos = const [],
    this.popularCreators = const [],
    this.trendingVideos = const [],
    this.featuredChannels = const [],
  });

  factory ClientHomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return ClientHomeDashboardModel(
      recentVideos: (data['recent_videos'] as List? ?? [])
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularCreators: (data['popular_creators'] as List? ?? [])
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingVideos: (data['trending_videos'] as List? ?? [])
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredChannels: (data['featured_channels'] as List? ?? [])
          .map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
