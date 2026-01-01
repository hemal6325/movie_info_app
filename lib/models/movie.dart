class Cast {
  final int id; // 🔥 এই লাইনটি মিসিং ছিল
  final String name;
  final String? profilePath;

  Cast({required this.id, required this.name, this.profilePath});

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'], // 🔥 এটাও মিসিং ছিল
      name: json['name'] ?? 'Unknown',
      profilePath: json['profile_path'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profile_path': profilePath,
  };
}

class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? releaseDate;
  final List<Cast>? cast;
  final String? trailerId;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    this.cast,
    this.trailerId,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    var castList = <Cast>[];
    if (json['credits'] != null && json['credits']['cast'] != null) {
      json['credits']['cast'].forEach((v) {
        castList.add(Cast.fromJson(v));
      });
    } else if (json['cast'] != null) {
      json['cast'].forEach((v) {
        castList.add(Cast.fromJson(v));
      });
    }

    String? trailer;
    if (json['videos'] != null && json['videos']['results'] != null) {
      var vids = json['videos']['results'] as List;
      for (var v in vids) {
        if (v['site'] == 'YouTube') {
          if (v['type'] == 'Trailer') {
            trailer = v['key'];
            break;
          } else if (v['type'] == 'Teaser') {
            trailer ??= v['key'];
          } else {
            trailer ??= v['key'];
          }
        }
      }
    }

    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: json['vote_average'] != null
          ? (json['vote_average'] as num).toDouble()
          : null,
      releaseDate: json['release_date'] as String?,
      cast: castList.isNotEmpty ? castList : null,
      trailerId: trailer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'cast': cast?.map((e) => e.toJson()).toList(),
    };
  }
}
