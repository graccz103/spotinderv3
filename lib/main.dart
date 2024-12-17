import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'spotify_service.dart';
import 'components/spotify_service/utils.dart';

void main() {
  // Tworzenie instancji SpotifyService z wymaganymi parametrami
  final spotifyService = SpotifyService(
    clientId: '2ee60615c2704ff2a0f06e3f9207a296',
    clientSecret: 'f2a9203eacd349b3bc9bcc93200a0e28',
  );

  runApp(MyApp(spotifyService: spotifyService));
}

class MyApp extends StatelessWidget {
  final SpotifyService spotifyService;

  const MyApp({Key? key, required this.spotifyService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Spotinder Home Page', spotifyService: spotifyService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final SpotifyService spotifyService;

  const MyHomePage({super.key, required this.title, required this.spotifyService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> artistData;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPreviewUrl;

  final List<Map<String, dynamic>> likedArtists = [];
  StreamSubscription? _sensorSubscription;
  bool _isActionPerformed = false;

  @override
  void initState() {
    super.initState();
    artistData = widget.spotifyService.getRandomArtist();

    _sensorSubscription = accelerometerEvents.listen((event) {
      if (!_isActionPerformed) {
        if (event.x < -7) {
          _isActionPerformed = true;
          _likeCurrentArtist();
        } else if (event.x > 7) {
          _isActionPerformed = true;
          _nextArtist();
        }
      }
      if (event.x.abs() < 3) {
        _isActionPerformed = false;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _nextArtist() {
    setState(() {
      artistData = widget.spotifyService.getRandomArtist();
      _currentPreviewUrl = null;
    });
  }

  void _likeCurrentArtist() async {
    var currentArtist = await artistData;
    setState(() {
      likedArtists.add(currentArtist);
    });
    _nextArtist();
  }

  void _playPreview(String url) async {
    if (_currentPreviewUrl == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentPreviewUrl = null;
      });
    } else {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedArtistsPage(likedArtists: likedArtists),
                ),
              );
            },
          ),
        ],
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
              var spotifyUrl = artist['top_track']?['spotify_url'];
              var followers = artist['followers']?['total'] ?? 0;

              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 0) {
                    _likeCurrentArtist();
                  } else if (details.velocity.pixelsPerSecond.dx < 0) {
                    _nextArtist();
                  }
                },
                child: SingleChildScrollView(
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
                        Text('Latest Album: $albumName', style: TextStyle(fontSize: 18)),
                        Text('Top Track: $topTrack', style: TextStyle(fontSize: 18)),
                        if (previewUrl != null)
                          ElevatedButton(
                            onPressed: () => _playPreview(previewUrl),
                            child: Text(_currentPreviewUrl == previewUrl
                                ? 'Stop Preview'
                                : 'Play Preview'),
                          ),
                        if (spotifyUrl != null)
                          ElevatedButton(
                            onPressed: () => openSpotifyLink(spotifyUrl),
                            child: const Text('Open in Spotify'),
                          ),
                        Text('Followers: $followers',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        const SizedBox(height: 20),
                        Text(
                          'Tilt phone left to like, right to skip!',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
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

class LikedArtistsPage extends StatelessWidget {
  final List<Map<String, dynamic>> likedArtists;

  const LikedArtistsPage({Key? key, required this.likedArtists}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Artists"),
      ),
      body: likedArtists.isEmpty
          ? const Center(child: Text("No liked artists yet."))
          : ListView.builder(
        itemCount: likedArtists.length,
        itemBuilder: (context, index) {
          var artist = likedArtists[index];
          var artistName = artist['name'] ?? 'Unknown';
          var imageUrl = artist['images']?.isNotEmpty == true
              ? artist['images'][0]['url']
              : null;

          return ListTile(
            leading: imageUrl != null
                ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : null,
            title: Text(artistName),
          );
        },
      ),
    );
  }
}
