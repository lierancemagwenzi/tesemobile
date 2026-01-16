import 'dart:convert';

class NotificationModel {
   int? id;
   String? title;
   int? userId;
   String? body;
   bool? opened;
   DateTime? createdAt;
   DateTime? updatedAt;

  NotificationModel({
    this.id,
    this.title,
    this.userId,
    this.body,
    this.opened,
    this.createdAt,
    this.updatedAt,
  });

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse Integers
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper to safely parse DateTime
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    // Note the use of snake_case for JSON keys due to Sequelize 'underscored: true'
    return NotificationModel(
      id: parseInt(json['id']),
      title: json['title'] as String?,
      userId: parseInt(json['user_id']),
      body: json['body'] as String?,
      opened: json['opened'] as bool?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    // Note: When sending back to the API, ensure keys match expected format
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'body': body,
      'opened': opened,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
