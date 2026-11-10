class Movie {
  Movie(this.id, this.title, this.poster, this.year, this.genres, this.rating);

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      json['id'],
      json['title'],
      json['medium_cover_image'],
      json['year'].toString(),
      List<String>.from(json['genres'] ?? []),
      json['rating'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'medium_cover_image': poster,
      'year': year,
      'genres': genres,
      'rating': rating,
    };
  }

  int id;
  String title;
  String poster;
  String year;
  List<String> genres;
  String rating;
}

class MovieListResponse {
  MovieListResponse(this.movies);

  List<Movie> movies;

  factory MovieListResponse.fromJson(Map<String, dynamic> json) {
    List<Movie> movies = [];
    List movieList = json['data']['movies'] ?? [];
    for (Map<String, dynamic> movie in movieList) {
      movies.add(Movie.fromJson(movie));
    }
    return MovieListResponse(movies);
  }
}

class MovieDetailsResponse {
  MovieDetailsResponse(
    this.likes,
    this.runtime,
    this.summary,
    this.screenshots,
    this.cast,
  );

  int? likes;
  int? runtime;
  String summary;
  List<String> screenshots;
  List<CastMember> cast;

  factory MovieDetailsResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> movie = json['data']['movie'];
    String summary = movie['description_full'] ?? '';
    if (summary.isEmpty) {
      summary = movie['description_intro'] ?? '';
    }

    List<String> screenshots = [];
    for (int number = 1; number <= 3; number++) {
      String image = movie['medium_screenshot_image$number'] ?? '';
      if (image.isNotEmpty) {
        screenshots.add(image);
      }
    }

    List<CastMember> cast = [];
    for (Map<String, dynamic> member in movie['cast'] ?? []) {
      cast.add(CastMember.fromJson(member));
    }

    return MovieDetailsResponse(
      movie['like_count'],
      movie['runtime'],
      summary,
      screenshots,
      cast,
    );
  }
}

class CastMember {
  CastMember(this.name, this.character, this.image);

  String name;
  String character;
  String image;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      json['name'] ?? '',
      json['character_name'] ?? '',
      json['url_small_image'] ?? '',
    );
  }
}
