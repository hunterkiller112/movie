import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'api_manager.dart';
import 'movie_cards.dart';
import 'movie_data.dart';
import '../details_and_profile/movie_details_screen.dart';
import 'movie_tabs.dart';
import '../details_and_profile/profile_screen.dart';

class MoviesScreen extends StatefulWidget {
  static const String routeName = '/movies';

  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  int selectedTab = 0;
  int featuredIndex = 1;
  late Future<List<Movie>> homeMoviesFuture = ApiManager.getMovies();
  late Future<List<Movie>> actionMoviesFuture = ApiManager.getMovies(
    genre: 'Action',
  );

  void selectTab(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedTab = index;
    });
  }

  void openMovie(Movie movie) {
    Navigator.pushNamed(
      context,
      MovieDetailsScreen.routeName,
      arguments: movie,
    );
  }

  Widget featuredCarousel(List<Movie> movies) {
    int currentIndex = featuredIndex.clamp(0, movies.length - 1);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            movies[currentIndex].poster,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.465, 1],
              colors: [
                Color(0xCC121312),
                Color(0x99121312),
                AppTheme.background,
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/available_now.png',
                width: 267,
                height: 93,
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  height: 351,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  viewportFraction: 0.55,
                  enableInfiniteScroll: false,
                  initialPage: currentIndex,
                  onPageChanged: (index, reason) {
                    setState(() {
                      featuredIndex = index;
                    });
                  },
                ),
                items: movies.map((movie) {
                  return SizedBox(
                    width: 234,
                    child: MovieCard(
                      movie: movie,
                      radius: 20,
                      onTap: () {
                        openMovie(movie);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 21),
              Image.asset(
                'assets/images/watch_now.png',
                width: 354,
                height: 146,
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget homeTab(List<Movie> movies) {
    return ListView(
      children: [
        featuredCarousel(movies),
        FutureBuilder<List<Movie>>(
          future: actionMoviesFuture,
          builder: (context, snapshot) {
            List<Movie> actionMovies = snapshot.data ?? [];
            if (actionMovies.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SizedBox(
                    height: 43,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Action', style: TextStyle(fontSize: 20)),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.yellow,
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            selectTab(2);
                          },
                          child: const Text('See More →'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: actionMovies.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      Movie movie = actionMovies[index];
                      return SizedBox(
                        width: 146,
                        child: MovieCard(
                          movie: movie,
                          radius: 20,
                          onTap: () {
                            openMovie(movie);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      FutureBuilder<List<Movie>>(
        future: homeMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load movies.'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        homeMoviesFuture = ApiManager.getMovies();
                      });
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          List<Movie> movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return const Center(child: Text('No movies found.'));
          }

          return homeTab(movies);
        },
      ),
      const SearchTab(),
      const BrowseTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: screens[selectedTab]),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 4, 9, 9),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BottomNavigationBar(
              currentIndex: selectedTab,
              onTap: selectTab,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Browse',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
