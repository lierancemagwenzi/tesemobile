class CountryModel {
  final String name;
  final String shortCode;
  final String longCode;
  final int id;
  CountryModel({
    required this.name,
    required this.shortCode,
    required this.longCode,
    required this.id,
  });

  // Factory to create CountryModel from JSON
  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name'] ?? '',
      shortCode: json['short_code'] ?? '',
      longCode: json['long_code'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  // Method to convert model back to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'short_code': shortCode, 'long_code': longCode};
  }

  /// Helper to generate the Flag Emoji based on the short_code (ISO 3166-1 alpha-2)
  String get flag {
    if (shortCode.length != 2) return '🌐';
    final int firstLetter = shortCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = shortCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
