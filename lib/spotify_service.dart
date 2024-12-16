import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class SpotifyService {
  final String clientId = '2ee60615c2704ff2a0f06e3f9207a296';
  final String clientSecret = 'f2a9203eacd349b3bc9bcc93200a0e28';

  // Pobieranie tokena dostępu
  Future<String> _getAccessToken() async {
    var response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body:
      'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret',
    );

    var data = jsonDecode(response.body);
    return data['access_token'];
  }

  // Pobieranie danych artysty
  Future<Map<String, dynamic>> getArtistData(Map<String, dynamic> artist) async {
    String artistId = artist['id'];
    String accessToken = await _getAccessToken();

    // Pobierz najnowszy album
    var latestAlbum = await getLatestAlbum(artistId, accessToken);
    artist['latest_album'] = latestAlbum.isNotEmpty
        ? latestAlbum
        : {'name': 'No album available'};

    // Pobierz topowy utwór
    var topTrack = await getTopTrack(artistId, accessToken);
    artist['top_track'] = topTrack.isNotEmpty
        ? topTrack
        : {
      'name': 'No track available',
      'preview_url': null,
      'spotify_url': null,
    };

    return artist;
  }



  // Pobieranie najnowszego albumu artysty
  Future<Map<String, dynamic>> getLatestAlbum(
      String artistId, String accessToken) async {
    var response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album&limit=1'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    var albumData = jsonDecode(response.body);
    if (albumData['items'] != null && albumData['items'].isNotEmpty) {
      return albumData['items'][0];
    } else {
      return {};
    }
  }

  // Pobieranie top utworu artysty
  Future<Map<String, dynamic>> getTopTrack(
      String artistId, String accessToken) async {
    var response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    var trackData = jsonDecode(response.body);
    if (trackData['tracks'] != null && trackData['tracks'].isNotEmpty) {
      var firstTrack = trackData['tracks'][0];
      return {
        'name': firstTrack['name'],
        'preview_url': firstTrack['preview_url'],
        'spotify_url': firstTrack['external_urls']['spotify'],
      };
    }
    return {};
  }

  // Pobieranie losowego artysty
  Future<Map<String, dynamic>> getRandomArtist() async {
    String accessToken = await _getAccessToken();
    String randomQuery = _getRandomQuery();

    // Wyszukaj artystę na podstawie losowego ciągu znaków
    var response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$randomQuery&type=artist&limit=1'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    var searchData = jsonDecode(response.body);

    if (searchData['artists'] != null &&
        searchData['artists']['items'].isNotEmpty) {
      var artist = searchData['artists']['items'][0];
      if (artist.containsKey('id')) {
        return getArtistData(artist);
      }
    }

    // Ponów próbę, jeśli nie znaleziono artysty
    return getRandomArtist();
  }

  // Generowanie losowego zapytania
  String _getRandomQuery() {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();

    // Losowa litera lub dwie litery
    int length = random.nextBool() ? 1 : 2;
    return List.generate(length, (_) => characters[random.nextInt(characters.length)])
        .join();
  }
}

// Funkcja otwierająca link do Spotify
Future<void> openSpotifyLink(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
