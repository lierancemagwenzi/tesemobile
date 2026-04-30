class DefaultLinkModel {
  final int? userId;
  final String? shortLink;
  final int? id;
  final String? originalLink;
  final int? linkId;

  final String? ecocash;
  final String? innbucks;

  final String? zimswitch;

  final String? visa;
  final String? mastercard;

  DefaultLinkModel({
    this.userId,
    this.shortLink,
    this.id,
    this.originalLink,
    this.linkId,
    this.ecocash,
    this.innbucks,
    this.mastercard,
    this.visa,
    this.zimswitch,
  });

  // Factory method to create a LinkModel from JSON
  factory DefaultLinkModel.fromJson(Map<String, dynamic> json) {
    return DefaultLinkModel(
      userId: json['user_id'] as int?,
      shortLink: json['short_link'] as String?,
      id: json['id'] as int?,
      originalLink: json['original_link'] as String?,
      linkId: json['link_id'] as int?,
      zimswitch: json['zimswitch'] as String?,
      visa: json['visa'] as String?,
      mastercard: json['mastercard'] as String?,
      innbucks: json['innbucks'] as String?,
      ecocash: json['ecocash'] as String?,
    );
  }

  // Method to convert LinkModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'short_link': shortLink,
      'id': id,
      'original_link': originalLink,
      'link_id': linkId,
    };
  }
}
