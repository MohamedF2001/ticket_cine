class MovieVideos {
  final int id;
  final List<Video> results;

  MovieVideos({
    required this.id,
    required this.results,
  });

  factory MovieVideos.fromJson(Map<String, dynamic> json) {
    return MovieVideos(
      id: json['id'],
      results: (json['results'] as List)
          .map((video) => Video.fromJson(video))
          .toList(),
    );
  }
}

class Video {
  final String iso6391;
  final String iso31661;
  final String name;
  final String key;
  final String site;
  final int size;
  final String type;
  final bool official;
  final String publishedAt;
  final String id;

  Video({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.id,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      iso6391: json['iso_639_1'],
      iso31661: json['iso_3166_1'],
      name: json['name'],
      key: json['key'],
      site: json['site'],
      size: json['size'],
      type: json['type'],
      official: json['official'],
      publishedAt: json['published_at'],
      id: json['id'],
    );
  }

  // Helper pour obtenir l'URL YouTube
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}