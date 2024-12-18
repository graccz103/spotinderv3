import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'album_service.dart';
import 'track_service.dart';

class ArtistService {
  final AuthService authService;
  final AlbumService albumService;
  final TrackService trackService;

  ArtistService({
    required this.authService,
    required this.albumService,
    required this.trackService,
  });

  /// Fetch a random artist, optionally filtered by genre
  Future<Map<String, dynamic>> getRandomArtist({
    required List<String> excludedIds,
    String? genre,
  }) async {
    String accessToken = await authService.getAccessToken();
    int maxRetries = 25; // Maximum number of retries
    int retries = 0; // Retry counter

    while (retries < maxRetries) {
      int offset = Random().nextInt(100); // Random offset
      String query = genre != null ? 'genre:$genre' : _getRandomQuery();

      var response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=$query&type=artist&limit=1&offset=$offset'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        var searchData = jsonDecode(response.body);

        if (searchData['artists']?['items']?.isNotEmpty == true) {
          var artist = searchData['artists']['items'][0];
          if (!excludedIds.contains(artist['id'])) {
            return artist; // Return artist if found and not excluded
          }
        }
      }

      retries++;
    }

    throw Exception("No artists found after $maxRetries attempts");
  }

  /// Fetch artist details including latest album and top track concurrently
  Future<Map<String, dynamic>> getArtistData(
      Map<String, dynamic> artist, String accessToken) async {
    String artistId = artist['id'];

    // Fetch the latest album and top track in parallel
    var results = await Future.wait([
      albumService.getLatestAlbum(artistId, accessToken),
      trackService.getTopTrack(artistId, accessToken),
    ]);

    // Assign results to the artist data
    artist['latest_album'] =
    results[0].isNotEmpty ? results[0] : {'name': 'No album available'};
    artist['top_track'] =
    results[1].isNotEmpty ? results[1] : {'name': 'No track available'};

    return artist;
  }

  /// Generate a random query string
  String _getRandomQuery() {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    return List.generate(
      random.nextBool() ? 1 : 2,
          (_) => characters[random.nextInt(characters.length)],
    ).join();
  }
}
