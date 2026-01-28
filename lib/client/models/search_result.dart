import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';

class SearchResult {
  final List<User> users;
  final List<Channel> channels;
  final List<Playlist> playlists;
  final List<Video> videos;

  SearchResult({
    required this.users,
    required this.channels,
    required this.playlists,
    required this.videos,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      // Mapping the 'users' list
      users:
          (json['creators'] as List?)
              ?.map((item) => User.fromJson(item))
              .toList() ??
          [],

      // Mapping the 'channels' list
      channels:
          (json['channels'] as List?)
              ?.map((item) => Channel.fromJson(item))
              .toList() ??
          [],

      // Mapping the 'playlists' list
      playlists:
          (json['playlists'] as List?)
              ?.map((item) => Playlist.fromJson(item))
              .toList() ??
          [],

      // Mapping the 'videos' list
      videos:
          (json['videos'] as List?)
              ?.map((item) => Video.fromJson(item))
              .toList() ??
          [],
    );
  }

  // Helper method to check if the entire search result is empty
  bool get isEmpty =>
      users.isEmpty && channels.isEmpty && playlists.isEmpty && videos.isEmpty;
}
