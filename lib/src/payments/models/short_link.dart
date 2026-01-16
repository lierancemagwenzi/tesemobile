class ShortLinkModel {
  final int? id;
  final String? originalLink;
  final String? shortLink; 
  final int? userId; 
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? clicks;
  ShortLinkModel({
    this.id,
    this.originalLink,
    this.shortLink,
    this.userId,
    this.createdAt,
    this.clicks,
    this.updatedAt,
  });

  // --- Static Helper Methods for Parsing ---

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  // --- Factory Constructor (FROM JSON) ---
  factory ShortLinkModel.fromJson(Map<String, dynamic> json) {
    return ShortLinkModel(
      id: _parseInt(json['id']),
      // Assuming API might use snake_case or camelCase for the link fields
      originalLink:
          json['original_link'] as String? ?? json['originalLink'] as String?,
      shortLink: json['short_link'] as String? ?? json['shortLink'] as String?,
      // Using 'user_id' as the expected API key
      userId: _parseInt(json['user_id']),
      clicks: _parseInt(json['clicks']),

      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_link': originalLink,
      'short_link': shortLink,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
