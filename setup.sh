#!/bin/bash

# StyleSwap AI - Lib Folder Structure Setup Script
# This script creates the complete folder structure with empty files

echo "🚀 Creating StyleSwap AI lib folder structure..."

# Navigate to lib directory (assuming you're in project root)
cd lib

# Remove default files
rm -f main.dart

# Create main directories
mkdir -p core/{constants,routes,utils}
mkdir -p models
mkdir -p providers
mkdir -p screens/{home,try_on,wardrobe,recommendations}
mkdir -p widgets/{common,cards,buttons}
mkdir -p services

echo "📁 Creating core files..."

# Core Constants
touch core/constants/app_colors.dart
touch core/constants/app_strings.dart
touch core/constants/app_styles.dart

# Core Routes
touch core/routes/app_routes.dart

# Core Utils
touch core/utils/permissions.dart

echo "📊 Creating model files..."

# Models
touch models/clothing_item.dart
touch models/outfit.dart
touch models/user_preferences.dart

echo "🔄 Creating provider files..."

# Providers
touch providers/wardrobe_provider.dart
touch providers/camera_provider.dart
touch providers/theme_provider.dart

echo "📱 Creating screen files..."

# Main Navigation
touch screens/main_navigation.dart

# Home Screen
touch screens/home/home_screen.dart

# Try-On Screen
touch screens/try_on/try_on_screen.dart

# Wardrobe Screen
touch screens/wardrobe/wardrobe_screen.dart

# Recommendations Screen
touch screens/recommendations/recommendations_screen.dart

echo "🎨 Creating widget files..."

# Common Widgets
touch widgets/common/star_rating.dart
touch widgets/common/custom_card.dart
touch widgets/common/custom_button.dart
touch widgets/common/category_chips.dart

# Card Widgets
touch widgets/cards/clothing_item_card.dart
touch widgets/cards/outfit_card.dart

echo "⚙️ Creating service files..."

# Services
touch services/camera_service.dart
touch services/storage_service.dart
touch services/image_service.dart

# Main entry point
touch main.dart

echo "✅ StyleSwap AI lib folder structure created successfully!"
echo ""
echo "📂 Created structure:"
echo "lib/"
echo "├── main.dart"
echo "├── core/"
echo "│   ├── constants/"
echo "│   │   ├── app_colors.dart"
echo "│   │   ├── app_strings.dart"
echo "│   │   └── app_styles.dart"
echo "│   ├── routes/"
echo "│   │   └── app_routes.dart"
echo "│   └── utils/"
echo "│       └── permissions.dart"
echo "├── models/"
echo "│   ├── clothing_item.dart"
echo "│   ├── outfit.dart"
echo "│   └── user_preferences.dart"
echo "├── providers/"
echo "│   ├── wardrobe_provider.dart"
echo "│   ├── camera_provider.dart"
echo "│   └── theme_provider.dart"
echo "├── screens/"
echo "│   ├── main_navigation.dart"
echo "│   ├── home/"
echo "│   │   └── home_screen.dart"
echo "│   ├── try_on/"
echo "│   │   └── try_on_screen.dart"
echo "│   ├── wardrobe/"
echo "│   │   └── wardrobe_screen.dart"
echo "│   └── recommendations/"
echo "│       └── recommendations_screen.dart"
echo "├── widgets/"
echo "│   ├── common/"
echo "│   │   ├── star_rating.dart"
echo "│   │   ├── custom_card.dart"
echo "│   │   ├── custom_button.dart"
echo "│   │   └── category_chips.dart"
echo "│   └── cards/"
echo "│       ├── clothing_item_card.dart"
echo "│       └── outfit_card.dart"
echo "└── services/"
echo "    ├── camera_service.dart"
echo "    ├── storage_service.dart"
echo "    └── image_service.dart"
echo ""
echo "🎯 Next steps:"
echo "1. Add your code to each file"
echo "2. Update pubspec.yaml with dependencies"
echo "3. Run 'flutter pub get'"
echo "4. Start coding! 🚀"