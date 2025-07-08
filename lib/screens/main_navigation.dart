import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/try-on');
        break;
      case 2:
        context.go('/wardrobe');
        break;
      case 3:
        context.go('/recommendations');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') {
      _currentIndex = 0;
    } else if (location == '/try-on') {
      _currentIndex = 1;
    } else if (location == '/wardrobe') {
      _currentIndex = 2;
    } else if (location == '/recommendations') {
      _currentIndex = 3;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Try-On',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            activeIcon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Recommendations',
          ),
        ],
      ),
    );
  }
}
