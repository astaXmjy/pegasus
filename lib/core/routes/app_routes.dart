import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/main_navigation.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/try_on/try_on_screen.dart';
import '../../screens/wardrobe/wardrobe_screen.dart';
import '../../screens/recommendations/recommendations_screen.dart';

class AppRoutes {
  static const home = '/';
  static const tryOn = '/try-on';
  static const wardrobe = '/wardrobe';
  static const recommendations = '/recommendations';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
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
    ],
  );
}
