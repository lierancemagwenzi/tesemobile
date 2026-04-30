import 'dart:convert';

class TagModel {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TagModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Factory to create a TagModel from JSON
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      name: json['name'],
      // Parsing strings into DateTime objects for easier use in Flutter
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Method to convert the model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper for displaying the tag in UI (like a Chip)
  @override
  String toString() => name;
}
