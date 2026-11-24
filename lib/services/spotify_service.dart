import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spotify_model.dart';

class SpotifyService {
  static const String _clientId = '1ab0fd0c9e6246bbabf8bc8c8cd317de';
  static const String _clientSecret = 'd5f875b4454a48b5a2276baa8f418571';

  static String? _accessToken;
  static DateTime _tokenExpires = DateTime.fromMillisecondsSinceEpoch(0);
  static final Map<String, String?> _imageCache = {};

  static Future<String?> _getToken() async {
    if (_accessToken != null && DateTime.now().isBefore(_tokenExpires)) return _accessToken;

    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'] as String?;
        final seconds = (data['expires_in'] as num?)?.toInt() ?? 3600;
        _tokenExpires = DateTime.now().add(Duration(seconds: seconds - 60));
        return _accessToken;
      }
    } catch (_) {}
    return null;
  }

  // Foto profil artis dari Spotify (dipakai sebagai thumbnail event).
  static Future<String?> getArtistImage(String artistName) async {
    final key = artistName.toLowerCase();
    if (_imageCache.containsKey(key)) return _imageCache[key];

    try {
      final token = await _getToken();
      if (token == null) return null;

      final res = await http.get(
        Uri.parse(
          'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(artistName)}&type=artist&limit=1',
        ),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final items = jsonDecode(res.body)['artists']['items'] as List;
      if (items.isEmpty) return null;

      final images = items[0]['images'] as List?;
      final url = (images != null && images.isNotEmpty) ? images[0]['url'] as String? : null;
      _imageCache[key] = url;
      return url;
    } catch (_) {
      return null;
    }
  }

  static Future<List<SpotifyTrack>> getArtistTracks(String artistName) async {
    try {
      final token = await _getToken();
      if (token != null) {
        final searchUrl = Uri.parse(
          'https://api.spotify.com/v1/search?q=${Uri.encodeComponent(artistName)}&type=artist&limit=1',
        );
        final searchRes = await http.get(
          searchUrl,
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 8));

        if (searchRes.statusCode == 200) {
          final searchData = jsonDecode(searchRes.body);
          final items = searchData['artists']['items'] as List;
          if (items.isNotEmpty) {
            final artistId = items[0]['id'];

            final tracksUrl = Uri.parse(
              'https://api.spotify.com/v1/artists/$artistId/top-tracks?market=ID',
            );
            final tracksRes = await http.get(
              tracksUrl,
              headers: {'Authorization': 'Bearer $token'},
            ).timeout(const Duration(seconds: 8));

            if (tracksRes.statusCode == 200) {
              final tracksData = jsonDecode(tracksRes.body);
              final tracksList = tracksData['tracks'] as List;

              return tracksList.map((t) {
                return SpotifyTrack(
                  id: t['id'] ?? '',
                  name: t['name'] ?? '',
                  artist: artistName,
                  previewUrl: t['preview_url'] as String?,
                );
              }).take(4).toList();
            }
          }
        }
      }
    } catch (_) {}

    return _getFallbackTracks(artistName);
  }

  static List<SpotifyTrack> _getFallbackTracks(String artist) {
    if (artist.toLowerCase().contains('coldplay')) {
      return [
        SpotifyTrack(id: '1', name: 'Yellow', artist: 'Coldplay', previewUrl: null),
        SpotifyTrack(id: '2', name: 'Viva La Vida', artist: 'Coldplay', previewUrl: null),
        SpotifyTrack(id: '3', name: 'Fix You', artist: 'Coldplay', previewUrl: null),
      ];
    } else if (artist.toLowerCase().contains('sheila')) {
      return [
        SpotifyTrack(id: '4', name: 'Dan...', artist: 'Sheila on 7', previewUrl: null),
        SpotifyTrack(id: '5', name: 'Sephia', artist: 'Sheila on 7', previewUrl: null),
        SpotifyTrack(id: '6', name: 'Film Favorit', artist: 'Sheila on 7', previewUrl: null),
      ];
    } else if (artist.toLowerCase().contains('hindia')) {
      return [
        SpotifyTrack(id: '7', name: 'Evaluasi', artist: 'Hindia', previewUrl: null),
        SpotifyTrack(id: '8', name: 'Secukupnya', artist: 'Hindia', previewUrl: null),
        SpotifyTrack(id: '9', name: 'Rumah Ke Rumah', artist: 'Hindia', previewUrl: null),
      ];
    } else {
      return [
        SpotifyTrack(id: '10', name: 'Hati-Hati di Jalan', artist: 'Tulus', previewUrl: null),
        SpotifyTrack(id: '11', name: 'Monokrom', artist: 'Tulus', previewUrl: null),
      ];
    }
  }
}
