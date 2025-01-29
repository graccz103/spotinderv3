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

  Future<Map<String, dynamic>> getRandomArtist({
    required List<String> excludedIds,
    String? genre,
  }) async {
    String accessToken = await authService.getAccessToken();
    int maxRetries = 25; // Max ponownych prób znalezienia artysty
    int retries = 0; // ile bylo prob

    while (retries < maxRetries) {
      int offset = Random().nextInt(100); // losowanko
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
            return artist;
          }
        }
      }

      retries++;
    }

    throw Exception("No artists found after $maxRetries attempts");
  }

 // Wczytywanie zanlezionego artysty
  Future<Map<String, dynamic>> getArtistData(
      Map<String, dynamic> artist, String accessToken) async {
    String artistId = artist['id'];

    // jego albumu top piosenki
    var results = await Future.wait([
      albumService.getLatestAlbum(artistId, accessToken),
      trackService.getTopTrack(artistId, accessToken),
    ]);

    // zapisanie tych danych
    artist['latest_album'] =
    results[0].isNotEmpty ? results[0] : {'name': 'No album available'};
    artist['top_track'] =
    results[1].isNotEmpty ? results[1] : {'name': 'No track available'};

    return artist;
  }

  // losowe szukanie
  String _getRandomQuery() {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    return List.generate(
      random.nextBool() ? 1 : 2,
          (_) => characters[random.nextInt(characters.length)],
    ).join();
  }

  // Pobieranie opisu artysty z Last.fm
  Future<String?> getArtistDescription(String artistName) async {
    const apiKey = '7261f7a1789dfa08cdba57d9abc8ba5d';
    final url = Uri.parse(
        'http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=$artistName&api_key=$apiKey&format=json&lang=en');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Pobieranie opis i usuwanie linku HTML na końcu
        String? description = data['artist']['bio']['summary'];
        if (description != null) {
          description = description.replaceAll(RegExp(r"<a href=.*?</a>"), '').trim();
        }
        return description ?? 'No description available.';
      } else {
        throw Exception('Failed to fetch artist description');
      }
    } catch (e) {
      print('Error fetching artist description: $e');
      return null;
    }
  }

}
