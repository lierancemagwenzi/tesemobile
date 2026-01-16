import 'package:smacredit/src/content-creator/models/channel_model.dart';

class MediaResponse {
  final Video video;
  final Channel channel;
  final bool hasAccess;
  final bool shouldPurchase;
  final String type;

  MediaResponse({
    required this.video,
    required this.channel,
    required this.hasAccess,
    required this.shouldPurchase,
    required this.type,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      video: Video.fromJson(json['video'] ?? {}),
      channel: Channel.fromJson(json['channel'] ?? {}),
      hasAccess: json['has_access'] ?? false,
      shouldPurchase: json['should_purchase'] ?? false,
      type: json['type'] ?? '',
    );
  }
}

