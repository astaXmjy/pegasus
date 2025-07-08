import 'package:uuid/uuid.dart';

class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String imagePath;
  final List<String> colors;
  final List<String> tags;
  final double rating;
  final bool isFavorite;
  final DateTime createdAt;

  ClothingItem({
    String? id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.colors,
    required this.tags,
    this.rating = 0.0,
    this.isFavorite = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      imagePath: json['imagePath'],
      colors: List<String>.from(json['colors']),
      tags: List<String>.from(json['tags']),
      rating: json['rating']?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'colors': colors,
      'tags': tags,
      'rating': rating,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ClothingItem copyWith({
    String? name,
    String? category,
    String? imagePath,
    List<String>? colors,
    List<String>? tags,
    double? rating,
    bool? isFavorite,
  }) {
    return ClothingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      colors: colors ?? this.colors,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
