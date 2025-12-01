import 'ui/phone_login.dart';
import 'ui/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'ui/create_profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:khodarkom_app/ui/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khodarkom_app/ui/favorites_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // ✅ added before
import 'package:khodarkom_app/ui/my_orders_screen.dart';
import 'package:khodarkom_app/language_controller.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Protect whole app from uncaught async errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔥 Flutter Error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔥 Unhandled error: $error');
    return true; // prevents crash
  };

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }



  final languageController = LanguageController();
  await languageController.loadSavedLocale();

  runApp(MyApp(languageController: languageController));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.languageController});

  final LanguageController languageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageController,
      builder: (context, _) {
        return LanguageScope(
          controller: languageController,
          child: MaterialApp(
            locale: languageController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ?? 'Khodarkom',
            debugShowCheckedModeBanner: false,
            builder: (context, child) => ScrollConfiguration(
              behavior: const _NoGlowScrollBehavior(), // ✅ smooth bounce scroll
              child: child!,
            ),
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Tajawal',
              platform: TargetPlatform.iOS, // 👈 smoother animations on iOS
              splashFactory:
                  NoSplash.splashFactory, // 👈 removes Android ripple
              highlightColor: Colors.transparent, // 👈 no dark overlay on tap
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2BBA5A),
              ),
              scaffoldBackgroundColor: const Color(0xFFF7FAF8),
            ),
            home: const Splash2(),
            routes: {
              '/phone-login': (context) => const PhoneLoginScreen(),
              '/create-profile': (context) => const CreateProfileScreen(),
              '/home': (context) => const HomeScreen(), // temporary home
              '/favorites': (context) => const FavoritesScreen(),
              '/my_orders': (context) => const MyOrdersScreen(),
            },
          ),
        );
      },
    );
  }
}

// ✅ smooth scroll physics for both Android/iOS
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(); // 👈 iOS bounce effect
}
