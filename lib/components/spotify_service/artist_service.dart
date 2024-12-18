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
    int maxRetries = 100; // Maksymalna liczba prób
    int retries = 0; // Licznik prób

    while (retries < maxRetries) {
      // Losowy offset
      int offset = Random().nextInt(100); // Zakładając maksymalną liczbę wyników = 100
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
            return artist; // Zwróć artystę, jeśli został znaleziony i nie jest wykluczony
          }
        }
      }

      retries++;
    }

    throw Exception("No artists found after $maxRetries attempts");
  }




  /// Fetch artist details including latest album and top track
  Future<Map<String, dynamic>> getArtistData(
      Map<String, dynamic> artist, String accessToken) async {
    String artistId = artist['id'];

    var latestAlbum = await albumService.getLatestAlbum(artistId, accessToken);
    artist['latest_album'] =
    latestAlbum.isNotEmpty ? latestAlbum : {'name': 'No album available'};

    var topTrack = await trackService.getTopTrack(artistId, accessToken);
    artist['top_track'] =
    topTrack.isNotEmpty ? topTrack : {'name': 'No track available'};

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
