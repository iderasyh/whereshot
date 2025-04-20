import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whereshot/screens/home_screen.dart';
import 'package:whereshot/screens/result_screen.dart';
import 'package:whereshot/screens/store_screen.dart';

enum AppRoute {
  home,
  result,
  store,
}

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.home:
        return '/';
      case AppRoute.result:
        return '/result';
      case AppRoute.store:
        return '/store';
    }
  }
  
  String get name {
    return toString().split('.').last;
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.result.path,
        name: AppRoute.result.name,
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: AppRoute.store.path,
        name: AppRoute.store.name,
        builder: (context, state) => const StoreScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
} 