import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = '2ee60615c2704ff2a0f06e3f9207a296';
  final String clientSecret = 'f2a9203eacd349b3bc9bcc93200a0e28';

  Future<String> _getAccessToken() async {
    var response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret',
    );

    var data = jsonDecode(response.body);
    return data['access_token'];
  }

  Future<Map<String, dynamic>> getArtistData(String artistId) async {
    String accessToken = await _getAccessToken();
    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    return jsonDecode(response.body);
  }
}
