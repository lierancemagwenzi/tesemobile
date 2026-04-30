import 'dart:convert';

import 'package:smacredit/src/models/UserModel.dart';

class StreamWatchUnlockModel {
  final String? key;
  final String? status;
  final bool valid;
  final String? message;
  final String? playbackUrl;
  StreamWatchUnlockModel({
    this.key,
    this.playbackUrl,
    this.status,
    required this.valid,
    this.message,
  });

  factory StreamWatchUnlockModel.fromJson(Map<String, dynamic> json) {
    return StreamWatchUnlockModel(
      key: json['key'] ?? '',
      playbackUrl: json['url'] ?? '',
      status: json['status'] ?? '',
      valid: json['valid'] ?? false,
      message: json['message'] ?? 'Something went wrong',
    );
  }
}

class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? streamUrl;
  final String? streamId;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final String? slug;
  final String? thumbnail;
  final bool hasPurchased;
  final bool isLive;
  final bool canJoin;
  final bool canStart;
  final bool isPast;
  final User? organizer;
  final int purchaseCount;
  final int duration;
  final bool isUpcoming;
  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.streamUrl,
    this.streamId,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.currency,
    this.slug,
    this.hasPurchased = false,
    this.canStart = false,
    this.canJoin = false,
    this.isLive = false,
    this.isPast = true,
    this.thumbnail,
    this.organizer,
    this.purchaseCount = 0,
    this.duration = 0,
    this.isUpcoming = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      streamUrl: json['stream_url'],
      streamId: json['stream_id'],
      purchaseCount: json['purchase_count'] ?? 0,
      // Parsing the ISO string from Sequelize into a Dart DateTime
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      // Handling potential int vs double issues from JSON
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'ZAR',
      slug: json['slug'],
      thumbnail: json['thumbnail'],
      hasPurchased: json['has_purchased'] ?? false,
      canJoin: json['can_join'] ?? false,
      canStart: json['can_start'] ?? false,
      isLive: json['is_live'] ?? false,
      isUpcoming: json['is_upcoming'] ?? false,
      isPast: json['is_past'] ?? false,
      organizer: json['organizer'] != null
          ? User.fromJson(json['organizer'])
          : null,
    );
  }

  set isNotified(bool isNotified) {}

  get isNotified {
    return false;
  }

  get rating => 0;

  get views => 0;
}

class Pagination {
  final int totalEvents;
  final int currentPage;
  final int totalPages;

  Pagination({
    required this.totalEvents,
    required this.currentPage,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalEvents: json['total_events'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class EventResponse {
  final bool success;
  final List<EventModel> events;
  final Pagination pagination;

  EventResponse({
    required this.success,
    required this.events,
    required this.pagination,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      success: json['success'] ?? false,
      events: (json['events'] as List)
          .map((e) => EventModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class EventDashboardResponse {
  final bool success;
  final List<EventModel> live;
  final EventModel? featuredUpcoming;
  final List<EventModel> nextUpcoming;
  final List<EventModel> past;

  EventDashboardResponse({
    required this.success,
    required this.live,
    this.featuredUpcoming,
    required this.nextUpcoming,
    required this.past,
  });

  factory EventDashboardResponse.fromJson(Map<String, dynamic> json) =>
      EventDashboardResponse(
        success: json["success"] ?? false,
        live: List<EventModel>.from(
          (json["live"] ?? []).map((x) => EventModel.fromJson(x)),
        ),
        featuredUpcoming: json["featured_upcoming"] == null
            ? null
            : EventModel.fromJson(json["featured_upcoming"]),
        nextUpcoming: List<EventModel>.from(
          (json["next_upcoming"] ?? []).map((x) => EventModel.fromJson(x)),
        ),
        past: List<EventModel>.from(
          (json["past"] ?? []).map((x) => EventModel.fromJson(x)),
        ),
      );
}
