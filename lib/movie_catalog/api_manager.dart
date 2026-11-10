import 'api_service.dart';
import 'movie_data.dart';

class ApiManager {
  static Future<List<Movie>> getMovies({
    String query = '',
    String genre = '',
  }) async {
    var response = await ApiService.dio.get(
      'list_movies.json',
      queryParameters: {
        if (query.isNotEmpty) 'query_term': query,
        if (genre.isNotEmpty) 'genre': genre,
      },
    );

    if (response.statusCode != 200 || response.data['status'] != 'ok') {
      throw Exception('Could not load movies.');
    }
    return MovieListResponse.fromJson(response.data).movies;
  }

  static Future<MovieDetailsResponse> getMovieDetails(int movieId) async {
    var response = await ApiService.dio.get(
      'movie_details.json',
      queryParameters: {
        'movie_id': movieId,
        'with_images': true,
        'with_cast': true,
      },
    );

    if (response.statusCode != 200 || response.data['status'] != 'ok') {
      throw Exception('Could not load movie details.');
    }

    return MovieDetailsResponse.fromJson(response.data);
  }

  static Future<List<Movie>> getSimilarMovies(int movieId) async {
    var response = await ApiService.dio.get(
      'movie_suggestions.json',
      queryParameters: {'movie_id': movieId},
    );

    if (response.statusCode != 200 || response.data['status'] != 'ok') {
      throw Exception('Could not load similar movies.');
    }
    return MovieListResponse.fromJson(response.data).movies;
  }
}
