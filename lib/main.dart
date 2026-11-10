import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'account_screens/auth_provider.dart';
import 'account_screens/auth_service.dart';
import 'account_screens/forgot_password_screen.dart';
import 'account_screens/register_screen.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'startup_and_onboarding/discover_screen.dart';
import 'startup_and_onboarding/genres_screen.dart';
import 'account_screens/login_screen.dart';
import 'details_and_profile/movie_details_screen.dart';
import 'movie_catalog/movie_storage.dart';
import 'movie_catalog/movies_screen.dart';
import 'startup_and_onboarding/reviews_screen.dart';
import 'startup_and_onboarding/splash_screen.dart';
import 'startup_and_onboarding/start_watching_screen.dart';
import 'details_and_profile/profile_screen.dart';
import 'startup_and_onboarding/watchlists_screen.dart';
import 'startup_and_onboarding/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Run Movies on Android to sign in.')),
        ),
      ),
    );
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MovieStorage.open();
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && user.emailVerified) {
    try {
      await MovieStorage.openUser(
        user.uid,
        user.displayName ?? user.email ?? '',
      );
    } catch (_) {
      await AuthService.signOut();
    }
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MoviesApp(),
    ),
  );
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        DiscoverScreen.routeName: (context) => const DiscoverScreen(),
        GenresScreen.routeName: (context) => const GenresScreen(),
        WatchlistsScreen.routeName: (context) => const WatchlistsScreen(),
        ReviewsScreen.routeName: (context) => const ReviewsScreen(),
        StartWatchingScreen.routeName: (context) => const StartWatchingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        ForgotPasswordScreen.routeName: (context) =>
            const ForgotPasswordScreen(),
        MoviesScreen.routeName: (context) => MovieStorage.userId == null
            ? const LoginScreen()
            : const MoviesScreen(),
        EditProfileScreen.routeName: (context) => MovieStorage.userId == null
            ? const LoginScreen()
            : const EditProfileScreen(),
        MovieDetailsScreen.routeName: (context) => MovieStorage.userId == null
            ? const LoginScreen()
            : const MovieDetailsScreen(),
      },
    );
  }
}
