import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';

class MusicSearchResponse {
  final bool success;
  final List<Video> tracks;
  final SearchPagination? pagination;

  MusicSearchResponse({
    required this.success,
    required this.tracks,
    this.pagination,
  });

  factory MusicSearchResponse.fromJson(Map<String, dynamic> json) {
    return MusicSearchResponse(
      success: json['success'] ?? false,
      tracks: (json['data'] as List? ?? [])
          .map((i) => Video.fromJson(i))
          .toList(),
      pagination: json['pagination'] != null
          ? SearchPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class SearchPagination {
  final int total;
  final int currentPage;
  final int totalPages;

  SearchPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      total: json['total'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
class PlaylistSearchResponse {
  final bool success;
  final List<Playlist> playlists;
  final SearchPagination? pagination;

  PlaylistSearchResponse({
    required this.success,
    required this.playlists,
    this.pagination,
  });

  factory PlaylistSearchResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistSearchResponse(
      success: json['success'] ?? false,
      playlists: (json['data'] as List? ?? [])
          .map((i) => Playlist.fromJson(i))
          .toList(),
      pagination: json['pagination'] != null
          ? SearchPagination.fromJson(json['pagination'])
          : null,
    );
  }
}
class ArtistSearchResponse {
  final bool success;
  final List<User> artists;
  final SearchPagination? pagination;

  ArtistSearchResponse({
    required this.success,
    required this.artists,
    this.pagination,
  });

  factory ArtistSearchResponse.fromJson(Map<String, dynamic> json) {
    return ArtistSearchResponse(
      success: json['success'] ?? false,
      artists: (json['data'] as List? ?? [])
          .map((i) => User.fromJson(i))
          .toList(),
      pagination: json['pagination'] != null
          ? SearchPagination.fromJson(json['pagination'])
          : null,
    );
  }
}
