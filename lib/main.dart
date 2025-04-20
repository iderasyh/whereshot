import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereshot/providers/service_providers.dart';
import 'package:whereshot/router/app_router.dart';
import 'package:whereshot/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Run the app with providers
  runApp(
    ProviderScope(
      overrides: [
        // Initialize SharedPreferences provider
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const WhereShot(),
    ),
  );
}

class WhereShot extends StatelessWidget {
  const WhereShot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WhereShot',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
