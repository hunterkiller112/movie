import 'package:flutter/material.dart';

import '../movie_catalog/movie_storage.dart';
import '../movie_catalog/movies_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        String route = MovieStorage.userId == null
            ? WelcomeScreen.routeName
            : MoviesScreen.routeName;
        Navigator.pushReplacementNamed(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/movies_logo.png',
                  width: 121,
                  height: 118,
                ),
              ),
            ),
            Image.asset('assets/images/route_logo.png', width: 180),
            const Text('Supervised by mahmoud ashraf'),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
