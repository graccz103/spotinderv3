import 'package:flutter/material.dart';
import 'spotify_service.dart'; // Pamiętaj o zaimportowaniu nowego pliku serwisowego
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Spotinder Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> artistData;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPreviewUrl;

  @override
  void initState() {
    super.initState();
    artistData = SpotifyService().getRandomArtist(); // Pobieranie losowego artysty
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPreview(String url) async {
    if (_currentPreviewUrl == url) {
      // Jeśli ten sam podgląd jest odtwarzany, zatrzymaj odtwarzanie
      await _audioPlayer.stop();
      setState(() {
        _currentPreviewUrl = null;
      });
    } else {
      // Odtwórz nowy podgląd
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentPreviewUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: artistData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.hasData && snapshot.data != null) {
              var artist = snapshot.data!;
              var artistName = artist['name'] ?? 'Unknown';
              var imageUrl = artist['images'] != null && artist['images'].isNotEmpty
                  ? artist['images'][0]['url']
                  : null;
              var albumName = artist['latest_album']?['name'] ?? 'Unknown';
              var topTrack = artist['top_track']?['name'] ?? 'Unknown';
              var previewUrl = artist['top_track']?['preview_url'];
              var spotifyUrl = artist['top_track']?['spotify_url']; // Dodano link do Spotify
              var followers = artist['followers']?['total'] ?? 0;

              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Artist Name: $artistName',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Text(
                        'Latest Album: $albumName',
                        style: TextStyle(fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Top Track: $topTrack',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      if (previewUrl != null)
                        ElevatedButton(
                          onPressed: () => _playPreview(previewUrl),
                          child: Text(
                            _currentPreviewUrl == previewUrl ? 'Stop Preview' : 'Play Preview',
                          ),
                        )
                      else if (spotifyUrl != null)
                        ElevatedButton(
                          onPressed: () => openSpotifyLink(spotifyUrl), // Otwieranie linku do Spotify
                          child: Text('Open in Spotify'),
                        )
                      else
                        Text(
                          'Preview not available for this track',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      Text(
                        'Followers: $followers',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text("No data available"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
