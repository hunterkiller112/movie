import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'api_manager.dart';
import 'movie_cards.dart';
import 'movie_data.dart';
import '../details_and_profile/movie_details_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String searchText = '';
  Future<List<Movie>>? searchResults;

  void searchMovies() {
    String query = searchText.trim();
    if (query.isEmpty) {
      return;
    }

    setState(() {
      searchResults = ApiManager.getMovies(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: IconButton(
                tooltip: 'Search movies',
                onPressed: searchMovies,
                icon: const Icon(Icons.search, color: Colors.white),
              ),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
            ),
            onChanged: (value) {
              searchText = value;
              if (value.isEmpty) {
                setState(() {
                  searchResults = null;
                });
              }
            },
            onSubmitted: (value) {
              searchMovies();
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Movie>>(
            future: searchResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none) {
                return Center(
                  child: Image.asset(
                    'assets/images/empty_movies.png',
                    width: 124,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Could not search. Try again.'),
                );
              }

              List<Movie> movies = snapshot.data ?? [];
              if (movies.isEmpty) {
                return const Center(child: Text('No movies found.'));
              }

              return GridView.count(
                primary: false,
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
                children: [
                  for (Movie movie in movies)
                    MovieCard(
                      movie: movie,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pushNamed(
                          context,
                          MovieDetailsScreen.routeName,
                          arguments: movie,
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  List<String> genres = ['Action', 'Adventure', 'Animation', 'Biography'];
  late Future<List<Movie>> genreMovies = ApiManager.getMovies(genre: genres[0]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTabController(
          length: genres.length,
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 10),
            labelPadding: const EdgeInsets.only(right: 8),
            labelColor: Colors.black,
            unselectedLabelColor: AppTheme.yellow,
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(16),
            ),
            onTap: (index) {
              setState(() {
                genreMovies = ApiManager.getMovies(genre: genres[index]);
              });
            },
            tabs: [
              for (String genre in genres)
                Tab(
                  height: 48,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.yellow, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(widthFactor: 1, child: Text(genre)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Movie>>(
            future: genreMovies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Could not load movies. Tap a genre to try again.',
                  ),
                );
              }

              List<Movie> movies = snapshot.data ?? [];
              if (movies.isEmpty) {
                return Center(
                  child: Image.asset(
                    'assets/images/empty_movies.png',
                    width: 124,
                  ),
                );
              }

              return GridView.count(
                primary: false,
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
                children: [
                  for (Movie movie in movies)
                    MovieCard(
                      movie: movie,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          MovieDetailsScreen.routeName,
                          arguments: movie,
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
