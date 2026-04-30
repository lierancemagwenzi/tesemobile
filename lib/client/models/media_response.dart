import 'package:smacredit/src/content-creator/models/channel_model.dart';

class MediaResponse {
  final Video video;
  final Channel channel;
  final Playlist playlist;
  final bool hasAccess;
  final bool shouldPurchase;
  final String type;
  final String accessReason;
  List<AdModel> ads;
  String? playbackToken;

  MediaResponse({
    required this.video,
    required this.channel,
    required this.hasAccess,
    required this.shouldPurchase,
    required this.type,
    required this.accessReason,
    required this.playlist,
    required this.ads,
    this.playbackToken,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      video: Video.fromJson(json['video'] ?? {}),
      channel: Channel.fromJson(json['channel'] ?? {}),
      hasAccess: json['has_access'] ?? false,
      playbackToken: json['playback_token'],
      shouldPurchase: json['should_purchase'] ?? false,
      type: json['type'] ?? '',
      playlist: Playlist.fromJson(json['playlist'] ?? {}),
      accessReason: json['access_reason'] ?? '',
      ads: json['ads'] != null
          ? (json['ads'] as List).map((i) => AdModel.fromJson(i)).toList()
          : [],
    );
  }
}

class AdModel {
  final int id;
  final String? brand;
  final String description;
  final String adUrl;
  final int playAt;
  final int skipTimer;
  final String? advertiserActionUrl;
  final int advertiserId;

  // Mutable state field
  bool hasPlayed;
  bool viewSent;

  AdModel({
    required this.id,
    this.brand,
    required this.adUrl,
    required this.playAt,
    required this.description,
    this.skipTimer = 5,
    this.advertiserActionUrl,
    this.hasPlayed = false,
    this.viewSent = false,
    required this.advertiserId, // Default to false
  });

  void markAsPlayed() => hasPlayed = true;

  void markAsViewSent() => viewSent = true;

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'],
      brand: json['brand'],
      description: json['description'],
      advertiserId: json['advertiser_id'],
      adUrl: json['ad_url'],
      playAt: json['play_at'] ?? 0,
      skipTimer: json['skip_timer'] ?? 5,
      advertiserActionUrl: json['advertiser_action_url'],
      hasPlayed: false,
    );
  }
}
