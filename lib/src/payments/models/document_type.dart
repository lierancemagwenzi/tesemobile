class DocumentTypeDetail {
  final int? id;
  final int? documentTypeAccountTypeId;
  final String? documentTypeAccountTypeName;
  final String? documentTypeName;
  final String? documentAccountTypeName;
  final DateTime? createdAt;

  DocumentTypeDetail({
    this.id,
    this.documentTypeAccountTypeId,
    this.documentTypeAccountTypeName,
    this.documentTypeName,
    this.documentAccountTypeName,
    this.createdAt,
  });

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory DocumentTypeDetail.fromJson(Map<String, dynamic> json) {
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

    return DocumentTypeDetail(
      id: parseInt(json['id']),
      documentTypeAccountTypeId: parseInt(json['documentTypeAccountTypeId']),
      documentTypeAccountTypeName:
          json['documentTypeAccountTypeName'] as String?,
      documentTypeName: json['documentTypeName'] as String?,
      documentAccountTypeName: json['documentAccountTypeName'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentTypeAccountTypeId': documentTypeAccountTypeId,
      'documentTypeAccountTypeName': documentTypeAccountTypeName,
      'documentTypeName': documentTypeName,
      'documentAccountTypeName': documentAccountTypeName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
