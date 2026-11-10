import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../movie_catalog/api_manager.dart';
import '../movie_catalog/movie_cards.dart';
import '../movie_catalog/movie_data.dart';
import '../movie_catalog/movie_storage.dart';

class MovieDetailsScreen extends StatefulWidget {
  static const String routeName = '/movie-details';

  const MovieDetailsScreen({super.key});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Future<MovieDetailsResponse>? detailsFuture;
  Future<List<Movie>>? similarMovies;

  Future<void> markAsWatched(Movie movie) async {
    try {
      await MovieStorage.addToHistory(movie);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save to History.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved to History.')));
  }

  Widget stat(IconData icon, String value) {
    return Expanded(
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.yellow),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! Movie) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No movie selected.')),
      );
    }

    Movie movie = arguments;
    bool saved = MovieStorage.watchList.any((item) => item.id == movie.id);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 630,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.poster,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  semanticLabel: movie.title,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33121312),
                        Color(0x66121312),
                        AppTheme.background,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        minimum: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: 'Back',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              tooltip: saved
                                  ? 'Remove from watchlist'
                                  : 'Save to watchlist',
                              onPressed: () async {
                                try {
                                  await MovieStorage.toggleWatchList(movie);
                                  if (mounted) setState(() {});
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not update Watch List.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                saved ? Icons.bookmark : Icons.bookmark_border,
                                color: saved ? AppTheme.yellow : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              movie.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              movie.year,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      markAsWatched(movie);
                    },
                    child: const Text(
                      'Mark as Watched',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<MovieDetailsResponse>(
                  future: detailsFuture ??= ApiManager.getMovieDetails(
                    movie.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    MovieDetailsResponse? details = snapshot.data;
                    if (details == null) {
                      return Column(
                        children: [
                          const Text('Could not load movie details.'),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                detailsFuture = ApiManager.getMovieDetails(
                                  movie.id,
                                );
                              });
                            },
                            child: const Text('Try again'),
                          ),
                        ],
                      );
                    }

                    int? runtime = details.runtime;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            stat(
                              Icons.favorite,
                              details.likes?.toString() ?? '-',
                            ),
                            const SizedBox(width: 10),
                            stat(
                              Icons.access_time_filled,
                              runtime != null && runtime > 0 ? '$runtime' : '-',
                            ),
                            const SizedBox(width: 10),
                            stat(Icons.star, movie.rating),
                          ],
                        ),
                        if (details.screenshots.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Screen Shots',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (String image in details.screenshots)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  image,
                                  height: 166,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                        FutureBuilder<List<Movie>>(
                          future: similarMovies ??= ApiManager.getSimilarMovies(
                            movie.id,
                          ),
                          builder: (context, snapshot) {
                            List<Movie> similar = snapshot.data ?? [];
                            if (similar.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 18),
                                const Text(
                                  'Similar',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GridView.count(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.68,
                                  children: [
                                    for (Movie item in similar)
                                      MovieCard(
                                        movie: item,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            MovieDetailsScreen.routeName,
                                            arguments: item,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        if (details.summary.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            details.summary,
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                        ],
                        if (details.cast.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Cast',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (CastMember member in details.cast)
                            Card(
                              color: AppTheme.surface,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: member.image.isEmpty
                                    ? null
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          member.image,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                title: Text(member.name),
                                subtitle: member.character.isEmpty
                                    ? null
                                    : Text(member.character),
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Genres',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (String genre in movie.genres)
                      Chip(
                        label: Text(genre),
                        backgroundColor: AppTheme.surface,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
