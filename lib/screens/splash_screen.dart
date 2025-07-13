import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // ADD THIS
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../providers/ml_provider.dart'; // ADD THIS

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _statusText = 'Loading...'; // ADD THIS - Track loading status

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

    // ADD THIS - Initialize ML services in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMLServices();
    });
  }

  // ADD THIS - Initialize ML services
  Future<void> _initializeMLServices() async {
    try {
      setState(() {
        _statusText = 'Initializing AI services...';
      });

      final mlProvider = context.read<MLProvider>();
      await mlProvider.initialize();

      setState(() {
        _statusText = 'AI Ready!';
      });

      // Small delay to show the ready status
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('ML initialization failed: $e');
      setState(() {
        _statusText = 'Ready!'; // Fallback if ML fails
      });
    }
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
            // Lottie Animation (UNCHANGED - keeps working)
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

            // App Name (UNCHANGED)
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

            // Tagline (ENHANCED - Updated for AI)
            const Text(
              'AI Virtual Try-On',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 64),

            // ENHANCED - Loading with ML status
            Column(
              children: [
                // Loading indicator (UNCHANGED)
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryPurple,
                  ),
                ),

                const SizedBox(height: 16),

                // ADD THIS - Status text with ML progress
                Text(
                  _statusText,
                  style: AppStyles.captionTextStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                // ADD THIS - ML Provider status indicator
                Consumer<MLProvider>(
                  builder: (context, mlProvider, child) {
                    if (mlProvider.isInitializing) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: mlProvider.initializationProgress,
                              backgroundColor: AppColors.cardDark,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI: ${(mlProvider.initializationProgress * 100).round()}%',
                              style: AppStyles.captionTextStyle.copyWith(
                                fontSize: 12,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (mlProvider.isInitialized) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Ready',
                              style: AppStyles.captionTextStyle.copyWith(
                                fontSize: 12,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
