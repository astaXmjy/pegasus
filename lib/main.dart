import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/theme_provider.dart';
import 'core/constants/app_colors.dart';
import 'services/camera_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CameraService.initialize();
  runApp(const StyleSwapApp());
}

class StyleSwapApp extends StatelessWidget {
  const StyleSwapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'StyleSwap AI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: AppColors.backgroundDark,
              primaryColor: AppColors.primaryPurple,
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
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: AppColors.cardDark,
                selectedItemColor: AppColors.primaryPurple,
                unselectedItemColor: AppColors.textSecondary,
                type: BottomNavigationBarType.fixed,
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
