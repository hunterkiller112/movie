import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'movie_data.dart';

class MovieStorage {
  static late Box _box;
  static String? userId;
  static String profileName = '';
  static String profilePhone = '';
  static int profileAvatar = 8;

  static Future<void> open() async {
    var directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
    _box = await Hive.openBox('movies');
  }

  static List<Movie> get watchList => _readMovies('watchList');

  static List<Movie> get history => _readMovies('history');

  static Future<void> openUser(String id, String name) async {
    if (!_box.containsKey('originalListsOwner')) {
      await _box.put('originalListsOwner', id);
    }
    Map? profile = _box.get('$id/profile');
    profileName = profile?['name'] ?? name;
    profilePhone = profile?['phone'] ?? '';
    profileAvatar = profile?['avatar'] ?? 8;
    userId = id;
  }

  static Future<void> saveProfile(
    String id,
    String name,
    String phone,
    int avatar,
  ) async {
    await _box.put('$id/profile', {
      'name': name,
      'phone': phone,
      'avatar': avatar,
    });
    if (userId == id) {
      profileName = name;
      profilePhone = phone;
      profileAvatar = avatar;
    }
  }

  static String _listKey(String key) {
    if (userId == null || userId == _box.get('originalListsOwner')) {
      return key;
    }
    return '$userId/$key';
  }

  static List<Movie> _readMovies(String key) {
    List data = _box.get(_listKey(key)) ?? [];
    List<Movie> movies = [];
    for (Map movie in data) {
      movies.add(Movie.fromJson(Map<String, dynamic>.from(movie)));
    }
    return movies;
  }

  static Future<void> _saveMovies(String key, List<Movie> movies) {
    return _box.put(_listKey(key), [
      for (Movie movie in movies) movie.toJson(),
    ]);
  }

  static Future<void> toggleWatchList(Movie movie) {
    List<Movie> movies = watchList;
    if (movies.any((item) => item.id == movie.id)) {
      movies.removeWhere((item) => item.id == movie.id);
    } else {
      movies.add(movie);
    }
    return _saveMovies('watchList', movies);
  }

  static Future<void> addToHistory(Movie movie) async {
    List<Movie> movies = history;
    if (!movies.any((item) => item.id == movie.id)) {
      movies.add(movie);
      await _saveMovies('history', movies);
    }
  }
}
