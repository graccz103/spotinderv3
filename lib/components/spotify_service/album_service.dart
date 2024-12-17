import 'dart:convert';
import 'package:http/http.dart' as http;

class AlbumService {
  Future<Map<String, dynamic>> getLatestAlbum(String artistId, String accessToken) async {
    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album&limit=1'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    var albumData = jsonDecode(response.body);
    return albumData['items']?.isNotEmpty == true ? albumData['items'][0] : {};
  }
}
