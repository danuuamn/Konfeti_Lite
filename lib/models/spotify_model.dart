class SpotifyTrack {
  final String id;
  final String name;
  final String artist;
  final String? previewUrl;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artist,
    this.previewUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      artist: (json['artist'] ?? '') as String,
      previewUrl: json['preview_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'preview_url': previewUrl,
    };
  }
}
