import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whereshot/providers/service_providers.dart';
import 'package:whereshot/screens/boarding_screen.dart';
import 'package:whereshot/screens/history_screen.dart';
import 'package:whereshot/screens/home_screen.dart';
import 'package:whereshot/screens/result_screen.dart';
import 'package:whereshot/screens/store_screen.dart';

enum AppRoute {
  boarding,
  home,
  result,
  store,
  history,
}

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.boarding:
        return '/boarding';
      case AppRoute.home:
        return '/home';
      case AppRoute.result:
        return '/result';
      case AppRoute.store:
        return '/store';
      case AppRoute.history:
        return '/history';
    }
  }
  
  String get name {
    return toString().split('.').last;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
    routes: [
      GoRoute(
        path: AppRoute.boarding.path,
        name: AppRoute.boarding.name,
        builder: (context, state) => const BoardingScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.result.path,
        name: AppRoute.result.name,
        builder: (context, state) => ResultScreen(
          detectionId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoute.store.path,
        name: AppRoute.store.name,
        builder: (context, state) => const StoreScreen(),
      ),
      GoRoute(
        path: AppRoute.history.path,
        name: AppRoute.history.name,
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authService.currentUser != null;
      final isLoggingIn = state.matchedLocation == AppRoute.boarding.path;

      print('Redirect check: isLoggedIn=$isLoggedIn, location=${state.matchedLocation}');

      if (!isLoggedIn && !isLoggingIn) {
        print('Redirecting to boarding...');
        return AppRoute.boarding.path;
      }

      if (isLoggedIn && isLoggingIn) {
        print('Redirecting to home...');
        return AppRoute.home.path;
      }

      print('No redirect needed.');
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
          onError: (Object error) => print('GoRouterRefreshStream Error: $error'),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
} 