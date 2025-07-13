import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ml_provider.dart'; // ADD THIS LINE
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Don't initialize camera service here - let providers handle it
  debugPrint('Dora App starting with AI capabilities...'); // ENHANCED MESSAGE

  runApp(const DoraApp()); // RENAMED from StyleSwapApp to DoraApp
}

class DoraApp extends StatelessWidget {
  // RENAMED class
  const DoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MLProvider()), // ADD THIS LINE
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Dora',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              primaryColor: AppColors.primaryPurple,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryPurple,
                secondary: AppColors.accentPink,
                surface: AppColors.cardDark,
                background: AppColors.backgroundDark,
                error: AppColors.error,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.backgroundDark,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryPurple),
                ),
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintStyle: const TextStyle(color: AppColors.textSecondary),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: AppColors.cardDark,
                selectedItemColor: AppColors.primaryPurple,
                unselectedItemColor: AppColors.textSecondary,
                type: BottomNavigationBarType.fixed,
              ),
              cardTheme: CardTheme(
                color: AppColors.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              useMaterial3: true,
            ),
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
