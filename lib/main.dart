import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SquadCiApp());
}

class SquadCiApp extends StatelessWidget {
  const SquadCiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AudioProvider()),
      ],
      child: MaterialApp(
        title: 'SQUAD CI',
        theme: ThemeData(
          primarySwatch: MaterialColor(
            AppColors.primaryOrange.value,
            <int, Color>{
              50: AppColors.primaryOrange.withOpacity(0.1),
              100: AppColors.primaryOrange.withOpacity(0.2),
              200: AppColors.primaryOrange.withOpacity(0.3),
              300: AppColors.primaryOrange.withOpacity(0.4),
              400: AppColors.primaryOrange.withOpacity(0.5),
              500: AppColors.primaryOrange,
              600: AppColors.primaryOrange.withOpacity(0.7),
              700: AppColors.primaryOrange.withOpacity(0.8),
              800: AppColors.primaryOrange.withOpacity(0.9),
              900: AppColors.primaryOrange,
            },
          ),
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
