import 'dart:convert';

class TermsResponse {
  final bool success;
  final TermsData data;

  TermsResponse({required this.success, required this.data});

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      success: json['success'],
      data: TermsData.fromJson(json['data']),
    );
  }
}

class TermsData {
  final TermsModel terms;
  final bool hasAccepted;

  TermsData({required this.terms, required this.hasAccepted});

  factory TermsData.fromJson(Map<String, dynamic> json) {
    return TermsData(
      terms: TermsModel.fromJson(json['terms']),
      hasAccepted: json['has_accepted'] ?? false,
    );
  }
}

class TermsModel {
  final int id;
  final String content;
  final String version;
  final bool isActive;
  final String target;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TermsModel({
    required this.id,
    required this.content,
    required this.version,
    required this.isActive,
    required this.target,
    this.createdAt,
    this.updatedAt,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['id'],
      content: json['content'],
      version: json['version'],
      isActive: json['is_active'] is int
          ? json['is_active'] == 1
          : json['is_active'], // Handles both boolean and tinyint(1)
      target: json['target'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'version': version,
      'is_active': isActive,
      'target': target,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
