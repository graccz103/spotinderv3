import 'package:flutter/material.dart';
import 'spotify_service.dart';
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

  // Lista ulubionych artystów
  final List<Map<String, dynamic>> likedArtists = [];

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

  // Przejście do następnego artysty
  void _nextArtist() {
    setState(() {
      artistData = SpotifyService().getRandomArtist();
      _currentPreviewUrl = null;
    });
  }

  // Dodawanie artysty do ulubionych
  void _likeArtist(Map<String, dynamic> artist) {
    setState(() {
      likedArtists.add(artist);
    });
    _nextArtist(); // Przejdź do następnego artysty
  }

  // Odtwarzanie podglądu utworu
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
              // Przejdź do ekranu ulubionych
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
                    // Swipe w prawo
                    _likeArtist(artist);
                  } else if (details.velocity.pixelsPerSecond.dx < 0) {
                    // Swipe w lewo
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
                              _currentPreviewUrl == previewUrl
                                  ? 'Stop Preview'
                                  : 'Play Preview',
                            ),
                          )
                        else if (spotifyUrl != null)
                          ElevatedButton(
                            onPressed: () => openSpotifyLink(spotifyUrl),
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
                        const SizedBox(height: 20),
                        Text(
                          'Swipe left to skip, swipe right to like!',
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

// Strona ulubionych artystów
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
          var imageUrl = artist['images'] != null && artist['images'].isNotEmpty
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
