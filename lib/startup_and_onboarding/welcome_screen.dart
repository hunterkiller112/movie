import 'package:flutter/material.dart';

import 'discover_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String routeName = '/welcome';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome_posters.png'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 32),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Find Your Next\nFavorite Movie Here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Get access to a huge library of movies to suit all tastes. You will surely like it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.6,
                        color: Color(0x99FFFFFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, DiscoverScreen.routeName);
                      },
                      child: const Text('Explore Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
