import 'package:smacredit/src/content-creator/models/channel_model.dart';

import '../../src/models/UserModel.dart';

class ClientDashboardModel {
  final List<Creator>? creators;
  final List<Category>? categories;
  final VideoWrapper? video;

  ClientDashboardModel({this.creators, this.categories, this.video});

  factory ClientDashboardModel.fromJson(Map<String, dynamic> json) {
    return ClientDashboardModel(
      creators: json['creators'] != null
          ? (json['creators'] as List).map((i) => Creator.fromJson(i)).toList()
          : [],
      categories: json['categories'] != null
          ? (json['categories'] as List)
                .map((i) => Category.fromJson(i))
                .toList()
          : [],
      video: json['video'] != null
          ? VideoWrapper.fromJson(json['video'])
          : null,
    );
  }
}

class Creator {
  final int? id;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;
  final User? user;

  Creator({this.id, this.userId, this.createdAt, this.updatedAt, this.user});

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      userId: json['user_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Category {
  final int? id;
  final String? name;
  final String? image;
  final String? color;
  final String? icon;
  final String? description;
  final int? videoCount;
  final List<Video>? videos;
  Category({
    this.id,
    this.name,
    this.image,
    this.icon,
    this.color,
    this.description,
    this.videoCount,
    this.videos,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      icon: json['icon'],
      color: json['color'],
      videos: json['videos'] != null
          ? (json['videos'] as List).map((i) => Video.fromJson(i)).toList()
          : null,
      description: json['description'],
      videoCount: json['videoCount'],
    );
  }
}

class VideoWrapper {
  final int? id;
  final int? videoId;
  final bool? status;
  final Video? video;

  VideoWrapper({this.id, this.videoId, this.status, this.video});

  factory VideoWrapper.fromJson(Map<String, dynamic> json) {
    return VideoWrapper(
      id: json['id'],
      videoId: json['video_id'],
      status: json['status'],
      video: json['video'] != null ? Video.fromJson(json['video']) : null,
    );
  }
}
