import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereshot/providers/service_providers.dart';
import 'package:whereshot/router/app_router.dart';
import 'package:whereshot/theme/app_theme.dart';

import 'env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Allow GoRouter to parse Flutter Forward deep links
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Initialize RevenueCat
  await _initializeRevenueCat();

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

Future<void> _initializeRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug); // Optional: for debugging

  PurchasesConfiguration configuration;
  // IMPORTANT: Replace with your actual API keys
  String googleApiKey = Env.revenueCatAndroidKey;
  String appleApiKey = Env.revenueCatIosKey;

  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(googleApiKey);
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(appleApiKey);
  } else {
    throw Exception('Unsupported platform for RevenueCat');
  }

  await Purchases.configure(configuration);

  // Optional: Set up listener for purchase updates
  Purchases.addCustomerInfoUpdateListener((customerInfo) {});
}

class WhereShot extends ConsumerWidget {
  const WhereShot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WhereShot',
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
