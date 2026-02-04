import 'dart:convert';

// --- VIDEO MODEL ---
class Video {
  final int id; // ID kept non-nullable as it's the primary key
  final String? title;
  final String? description;
  final String? slug;
  final String? contentRating;
  final String? accessType;
  final double? price;
  final String? currency;
  final String? sourceFileUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final int? fileSizeBytes;
  final String? resolutionMax;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? playlistId;
  final int? channelId;
  final String? output;
  final String? jobStatus;
  final String? jobId;

  final String? trailer;
  final int? trailerDuration;

  final String? visibility;

  final int? videoCount;
  final int? hasPurchased;

  final bool? hasAccess;
  final String? playStatus;

  final int? likeCount;
  final int? viewCount;
  final int? downloadCount;
  Video({
    required this.id,
    this.title,
    this.description,
    this.slug,
    this.contentRating,
    this.accessType,
    this.price,
    this.currency,
    this.sourceFileUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.fileSizeBytes,
    this.resolutionMax,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.playlistId,
    this.channelId,
    this.jobStatus,
    this.jobId,
    this.output,
    this.trailer,
    this.trailerDuration,
    this.visibility,
    this.hasPurchased,
    this.videoCount,
    this.hasAccess,
    this.playStatus,
    this.likeCount,
    this.viewCount,
    this.downloadCount,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      slug: json['slug'],
      output: json['output'],
      jobStatus: json['job_status'],
      jobId: json['job_id'],
      contentRating: json['content_rating'],
      accessType: json['access_type'],
      price: double.tryParse(json['price']?.toString() ?? ''),
      currency: json['currency'],
      sourceFileUrl: json['source_file_url'],
      thumbnailUrl: json['thumbnail_url'],
      durationSeconds: json['duration_seconds'],
      fileSizeBytes: json['file_size_bytes'],
      resolutionMax: json['resolution_max'],
      status: json['status'],
      hasPurchased: json['hasPurchased'],
      hasAccess: json['has_access'] != null && json['has_access'] == 1,
      playStatus: json['play_status'],
      likeCount: json['like_count'],
      viewCount: json['view_count'],
      downloadCount: json['download_count'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      playlistId: json['playlist_id'],
      channelId: json['channel_id'],
      trailer: json['trailer'],
      trailerDuration: json['trailer_duration'],
      visibility: json['visibility'],
    );
  }

  // bool hasAccess(Channel channel) {
  //   if (accessType?.toLowerCase() == 'paid') {
  //     if (hasPurchased == 1 || channel.hasAccess) {
  //       return true;
  //     }

  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  String get getFileName {
    return "${slug}_$id.mp4";
  }
}

// --- PLAYLIST MODEL ---
class Playlist {
  final int id;
  final String? title;
  final String? description;
  final String? type;
  final double? price;
  final String? currency;
  final String? thumbnailUrl;
  final bool? isPublic;
  final List<Video>? videos;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? channelId;
  final int? videoCount;
  final int? hasPurchased;
  Playlist({
    required this.id,
    this.title,
    this.description,
    this.type,
    this.price,
    this.currency,
    this.thumbnailUrl,
    this.isPublic,
    this.videos,
    this.createdAt,
    this.updatedAt,
    this.channelId,
    this.hasPurchased,
    this.videoCount,
  });

  Map get shouldShowButton {
    if (type == 'paid') {
      if (hasPurchased == 1) {
        return {
          'status': "subscribed",
          'message': 'Subscribed',
          'positive': true,
        };
      }

      return {
        'status': "not_subscribed",
        'message': 'Subscribe',
        'positive': false,
      };
    }

    return {'status': "free", 'message': 'Free Playlist', 'positive': true};
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      price: double.tryParse(json['price']?.toString() ?? ''),
      currency: json['currency'],
      thumbnailUrl: json['thumbnail_url'],
      isPublic: json['is_public'],
      videoCount: json['videoCount'],
      hasPurchased: json['hasPurchased'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      channelId: json['channel_id'],
      videos: json['videos'] != null
          ? (json['videos'] as List).map((i) => Video.fromJson(i)).toList()
          : [],
    );
  }
}

// --- CHANNEL MODEL ---
class Channel {
  final int id;
  final int? userId;
  final String? name;
  final String? slug;
  final String? description;
  final String? coverImageUrl;
  final String? logoUrl;
  final bool? subscriptionEnabled;
  final double? subscriptionPrice;
  final String? subscriptionCurrency;
  final String? subscriptionPeriod;
  final bool? isPublic;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Playlist>? playlists;

  final int? hasPurchased;
  final int? playlistCount;
  final int? videoCount;

  Channel({
    required this.id,
    this.userId,
    this.name,
    this.slug,
    this.description,
    this.coverImageUrl,
    this.logoUrl,
    this.subscriptionEnabled,
    this.subscriptionPrice,
    this.subscriptionCurrency,
    this.subscriptionPeriod,
    this.isPublic,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.playlists,
    this.hasPurchased,
    this.playlistCount,
    this.videoCount,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      hasPurchased: json['hasPurchased'],
      playlistCount: json['playlistCount'],
      videoCount: json['videoCount'],
      coverImageUrl: json['cover_image_url'],
      logoUrl: json['logo_url'],
      subscriptionEnabled: json['subscription_enabled'],
      subscriptionPrice: double.tryParse(
        json['subscription_price']?.toString() ?? '',
      ),
      subscriptionCurrency: json['subscription_currency'],
      subscriptionPeriod: json['subscription_period'],
      isPublic: json['is_public'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      playlists: json['playlists'] != null
          ? (json['playlists'] as List)
                .map((i) => Playlist.fromJson(i))
                .toList()
          : [],
    );
  }

  Map get shouldShowButton {
    if (subscriptionEnabled == true) {
      if (hasPurchased == 1) {
        return {
          'status': "subscribed",
          'message': 'Subscribed',
          'positive': true,
        };
      }

      return {
        'status': "not_subscribed",
        'message': 'Subscribe',
        'positive': false,
      };
    }

    return {'status': "free", 'message': 'Free Channel', 'positive': true};
  }

  bool get hasAccess {
    if (subscriptionEnabled == true) {
      if (hasPurchased == 1) {
        return true;
      }

      return false;
    } else {
      return true;
    }
  }
}
