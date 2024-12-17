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

  Future<Map<String, dynamic>> getRandomArtist({required List<String> excludedIds}) async {
    String accessToken = await authService.getAccessToken();
    String randomQuery = _getRandomQuery();

    int retries = 0; // Liczba prób uniknięcia duplikatów
    while (retries < 10) { // Maksymalna liczba prób
      var response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$randomQuery&type=artist&limit=1'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      var searchData = jsonDecode(response.body);
      if (searchData['artists']?['items']?.isNotEmpty == true) {
        var artist = searchData['artists']['items'][0];
        String artistId = artist['id'];

        // Sprawdzenie czy ID artysty znajduje się na liście ulubionych
        if (!excludedIds.contains(artistId)) {
          return await getArtistData(artist, accessToken);
        }
      }
      // Ponowna próba jeśli artysta się powtarza
      randomQuery = _getRandomQuery();
      retries++;
    }

    throw Exception("Unable to fetch a unique artist after multiple attempts");
  }

  Future<Map<String, dynamic>> getArtistData(
      Map<String, dynamic> artist, String accessToken) async {
    String artistId = artist['id'];

    var latestAlbum = await albumService.getLatestAlbum(artistId, accessToken);
    artist['latest_album'] = latestAlbum.isNotEmpty ? latestAlbum : {'name': 'No album available'};

    var topTrack = await trackService.getTopTrack(artistId, accessToken);
    artist['top_track'] = topTrack.isNotEmpty ? topTrack : {'name': 'No track available'};

    return artist;
  }

  String _getRandomQuery() {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    return List.generate(random.nextBool() ? 1 : 2,
            (_) => characters[random.nextInt(characters.length)])
        .join();
  }
}
