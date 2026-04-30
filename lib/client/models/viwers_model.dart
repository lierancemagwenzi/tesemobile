class ViewersModel {
  final int viewers;

  ViewersModel({required this.viewers});

  // Factory to create model from JSON {viewers: 34}
  factory ViewersModel.fromJson(Map<String, dynamic> json) {
    return ViewersModel(viewers: json['viewers'] ?? 0);
  }

  // To JSON if you need to send it back to Firestore/API
  Map<String, dynamic> toJson() {
    return {'viewers': viewers};
  }

  // Helper to display "34K" or "1.2M" instead of raw numbers
  String get formattedViewers {
    if (viewers >= 1000000) {
      return '${(viewers / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (viewers >= 1000) {
      return '${(viewers / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return viewers.toString();
  }
}
