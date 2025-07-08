import 'package:uuid/uuid.dart';

class Outfit {
  final String id;
  final String name;
  final String description;
  final List<String> clothingItemIds;
  final double rating;
  final String style;
  final String occasion;
  final String imagePath;
  final DateTime createdAt;

  Outfit({
    String? id,
    required this.name,
    required this.description,
    required this.clothingItemIds,
    required this.rating,
    required this.style,
    required this.occasion,
    required this.imagePath,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      clothingItemIds: List<String>.from(json['clothingItemIds']),
      rating: json['rating']?.toDouble() ?? 0.0,
      style: json['style'],
      occasion: json['occasion'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'clothingItemIds': clothingItemIds,
      'rating': rating,
      'style': style,
      'occasion': occasion,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
