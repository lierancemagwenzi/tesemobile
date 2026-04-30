class ContentRating {
  final String? name;
  final String? message;
  final bool triggerWarning;
  final String? icon;
int? id;
  ContentRating({
    this.name,
    this.message,
    this.triggerWarning = false,
    this.icon,this.id
  });

  // Factory constructor to create a ContentRating from JSON
  factory ContentRating.fromJson(Map<String, dynamic> json) {
    return ContentRating(
      name: json['name'] as String?,
       id: json['id'] as int?,
      message: json['message'] as String?,
      // Handle potential nulls or integer/bool variations from SQL
      triggerWarning:
          json['trigger_warning'] == true || json['trigger_warning'] == 1,
      icon: json['icon'] as String?,
    );
  }

  // Method to convert the model back to JSON (useful for POST requests)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'trigger_warning': triggerWarning,
      'icon': icon,
    };
  }
}
