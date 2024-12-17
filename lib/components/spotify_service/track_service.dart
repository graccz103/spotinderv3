import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackService {
  Future<Map<String, dynamic>> getTopTrack(String artistId, String accessToken) async {
    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    var trackData = jsonDecode(response.body);
    if (trackData['tracks']?.isNotEmpty == true) {
      var firstTrack = trackData['tracks'][0];
      return {
        'name': firstTrack['name'],
        'preview_url': firstTrack['preview_url'],
        'spotify_url': firstTrack['external_urls']['spotify'],
      };
    }
    return {};
  }
}
