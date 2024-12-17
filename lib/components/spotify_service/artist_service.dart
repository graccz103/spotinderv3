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

  Future<Map<String, dynamic>> getRandomArtist() async {
    String accessToken = await authService.getAccessToken();
    String randomQuery = _getRandomQuery();

    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$randomQuery&type=artist&limit=1'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    var searchData = jsonDecode(response.body);
    if (searchData['artists']?['items']?.isNotEmpty == true) {
      var artist = searchData['artists']['items'][0];
      return await getArtistData(artist, accessToken);
    }
    return getRandomArtist(); // Ponów próbę, jeśli brak artysty
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
