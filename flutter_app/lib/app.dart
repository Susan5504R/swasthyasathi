import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/home/home_screen.dart';
import 'screens/auth/phone_login_screen.dart';
import 'screens/auth/otp_verify_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/scan/processing_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SwasthyaSathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// Router configuration with error-safe redirect
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = state.matchedLocation;
    final isAuthRoute = currentPath == '/login' || currentPath == '/verify-otp';

    // Not logged in → force to login (unless already there)
    if (user == null) {
      return isAuthRoute ? null : '/login';
    }

    // Logged in → check if profile exists in Firestore
    if (isAuthRoute || currentPath == '/') {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          // New user, needs onboarding
          return currentPath == '/onboarding' ? null : '/onboarding';
        }
        // Profile exists, send to home if on auth pages
        return isAuthRoute ? '/' : null;
      } catch (e) {
        // If Firestore check fails, send to onboarding as a safe fallback
        debugPrint('Firestore profile check failed: $e');
        return '/onboarding';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final verificationId = state.extra as String? ?? '';
        return OtpVerifyScreen(verificationId: verificationId);
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/processing',
      builder: (context, state) {
        final args = state.extra as Map<String, String>? ?? {};
        return ProcessingScreen(
          uid: args['uid'] ?? '',
          docId: args['docId'] ?? '',
        );
      },
    ),
  ],
);
