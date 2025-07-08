class UserPreferences {
  final String userId;
  final List<String> favoriteStyles;
  final List<String> preferredColors;
  final String bodyType;
  final Map<String, dynamic> measurements;
  final DateTime lastUpdated;

  UserPreferences({
    required this.userId,
    required this.favoriteStyles,
    required this.preferredColors,
    required this.bodyType,
    required this.measurements,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'],
      favoriteStyles: List<String>.from(json['favoriteStyles']),
      preferredColors: List<String>.from(json['preferredColors']),
      bodyType: json['bodyType'],
      measurements: Map<String, dynamic>.from(json['measurements']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteStyles': favoriteStyles,
      'preferredColors': preferredColors,
      'bodyType': bodyType,
      'measurements': measurements,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
