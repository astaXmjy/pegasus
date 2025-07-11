import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);

    // Navigate to home after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    // Add a small delay before navigation for better UX
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/animation/animation.json', // Your JSON file name
              controller: _animationController,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                // Start animation when loaded
                _animationController
                  ..duration = composition.duration
                  ..forward();
              },
            ),

            const SizedBox(height: 32),

            // App Name
            const Text(
              'Dora',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Unleash Your Style',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 64),

            // Loading indicator (optional)
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
