import 'dart:convert';

class VideoReviewModel {
  int? id;
  String? description;
  String? reason;
  int? userId;
  int? videoId;
  DateTime? createdAt;
  DateTime? updatedAt;

  VideoReviewModel({
    this.id,
    this.description,
    this.userId,
    this.videoId,
    this.createdAt,
    this.updatedAt,this.reason
  });

  factory VideoReviewModel.fromJson(Map<String, dynamic> json) {
    return VideoReviewModel(
      id: json['id'],
      description: json['description'],
       reason: json['reason'],
      userId: json['user_id'],
      videoId: json['video_id'],
      // Parsing strings into DateTime objects
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "description": description,
      "user_id": userId,
      "video_id": videoId,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
