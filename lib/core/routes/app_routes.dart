import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart'; // ADD THIS
import '../../screens/main_navigation.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/try_on/try_on_screen.dart';
import '../../screens/wardrobe/wardrobe_screen.dart';
import '../../screens/wardrobe/add_clothing_screen.dart';
import '../../screens/wardrobe/edit_clothing_screen.dart';
import '../../screens/wardrobe/clothing_detail_screen.dart';
import '../../screens/recommendations/recommendations_screen.dart';

class AppRoutes {
  static const splash = '/splash'; // ADD THIS
  static const home = '/';
  static const tryOn = '/try-on';
  static const wardrobe = '/wardrobe';
  static const addClothing = '/wardrobe/add';
  static const editClothing = '/wardrobe/edit';
  static const clothingDetail = '/wardrobe/item';
  static const recommendations = '/recommendations';

  static final GoRouter router = GoRouter(
    initialLocation: splash, // CHANGE THIS to start with splash
    routes: [
      // Splash screen route (outside shell)
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: tryOn,
            builder: (context, state) => const TryOnScreen(),
          ),
          GoRoute(
            path: wardrobe,
            builder: (context, state) => const WardrobeScreen(),
          ),
          GoRoute(
            path: recommendations,
            builder: (context, state) => const RecommendationsScreen(),
          ),
        ],
      ),
      // Other full-screen routes
      GoRoute(
        path: addClothing,
        builder: (context, state) => const AddClothingScreen(),
      ),
      GoRoute(
        path: '$editClothing/:id',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return EditClothingScreen(itemId: itemId);
        },
      ),
      GoRoute(
        path: '$clothingDetail/:id',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return ClothingDetailScreen(itemId: itemId);
        },
      ),
    ],
  );
}
