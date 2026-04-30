import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';

class MusicDashboardResponse {
  final bool success;
  final MusicDiscoveryData data;

  MusicDashboardResponse({required this.success, required this.data});

  factory MusicDashboardResponse.fromJson(Map<String, dynamic> json) {
    return MusicDashboardResponse(
      success: json['success'] ?? false,
      data: MusicDiscoveryData.fromJson(json['data'] ?? {}),
    );
  }
}

class MusicDiscoveryData {
  final List<Category> genres;
  final List<User> artists;
  final List<Playlist> albums;
  final List<Video> latest;

  MusicDiscoveryData({
    required this.genres,
    required this.artists,
    required this.albums,
    required this.latest,
  });

  factory MusicDiscoveryData.fromJson(Map<String, dynamic> json) {
    return MusicDiscoveryData(
      genres: (json['genres'] as List? ?? [])
          .map((i) => Category.fromJson(i))
          .toList(),
      artists: (json['artists'] as List? ?? [])
          .map((i) => User.fromJson(i))
          .toList(),
      albums: (json['albums'] as List? ?? [])
          .map((i) => Playlist.fromJson(i))
          .toList(),
      latest: (json['latest'] as List? ?? [])
          .map((i) => Video.fromJson(i))
          .toList(),
    );
  }
}
class TrendingMusicResponse {
  final bool success;
  final TrendingData data;

  TrendingMusicResponse({required this.success, required this.data});

  factory TrendingMusicResponse.fromJson(Map<String, dynamic> json) {
    return TrendingMusicResponse(
      success: json['success'] ?? false,
      data: TrendingData.fromJson(json['data'] ?? {}),
    );
  }
}

class TrendingData {
  final List<User> trendingArtists;
  final List<Video> trendingTracks;
  final List<Playlist> trendingAlbums;

  TrendingData({
    required this.trendingArtists,
    required this.trendingTracks,
    required this.trendingAlbums,
  });

  factory TrendingData.fromJson(Map<String, dynamic> json) {
    return TrendingData(
      trendingArtists: (json['trending_artists'] as List? ?? [])
          .map((i) => User.fromJson(i))
          .toList(),
      trendingTracks: (json['trending_tracks'] as List? ?? [])
          .map((i) => Video.fromJson(i))
          .toList(),
      trendingAlbums: (json['trending_albums'] as List? ?? [])
          .map((i) => Playlist.fromJson(i))
          .toList(),
    );
  }
}


class GenreArtistResponse {
  final bool success;
  final Category? category;
  final List<User> artists;
  final GenrePagination? pagination;

  GenreArtistResponse({
    required this.success,
    this.category,
    required this.artists,
    this.pagination,
  });

  factory GenreArtistResponse.fromJson(Map<String, dynamic> json) {
    return GenreArtistResponse(
      success: json['success'] ?? false,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      artists: (json['artists'] as List? ?? [])
          .map((i) => User.fromJson(i))
          .toList(),
      pagination: json['pagination'] != null
          ? GenrePagination.fromJson(json['pagination'])
          : null,
    );
  }
}





class GenrePagination {
  final int total;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  GenrePagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory GenrePagination.fromJson(Map<String, dynamic> json) {
    return GenrePagination(
      total: json['total'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}


class GenreAlbumResponse {
  final bool success;
  final List<Playlist> albums;
  final AlbumPagination? pagination;

  GenreAlbumResponse({
    required this.success,
    required this.albums,
    this.pagination,
  });

  factory GenreAlbumResponse.fromJson(Map<String, dynamic> json) {
    return GenreAlbumResponse(
      success: json['success'] ?? false,
      albums: (json['data'] as List? ?? [])
          .map((i) => Playlist.fromJson(i))
          .toList(),
      pagination: json['pagination'] != null
          ? AlbumPagination.fromJson(json['pagination'])
          : null,
    );
  }
}


class AlbumPagination {
  final int total;
  final int currentPage;
  final int totalPages;

  AlbumPagination({
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory AlbumPagination.fromJson(Map<String, dynamic> json) {
    return AlbumPagination(
      total: json['total'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
