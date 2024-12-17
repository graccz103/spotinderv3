import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../spotify_service.dart';
import 'liked_artists_page.dart';
import '../../components/spotify_service/utils.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final SpotifyService spotifyService;

  const MyHomePage({Key? key, required this.title, required this.spotifyService})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> artistData;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPreviewUrl;

  final List<Map<String, dynamic>> likedArtists = [];
  bool _isActionPerformed = false;

  @override
  void initState() {
    super.initState();
    artistData = widget.spotifyService.getRandomArtist();
    _listenToAccelerometer();
  }

  void _listenToAccelerometer() {
    accelerometerEvents.listen((event) {
      if (!_isActionPerformed) {
        if (event.x < -7) {
          _isActionPerformed = true;
          _likeCurrentArtist();
        } else if (event.x > 7) {
          _isActionPerformed = true;
          _nextArtist();
        }
      }
      if (event.x.abs() < 3) _isActionPerformed = false;
    });
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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var artist = snapshot.data!;
            var artistName = artist['name'] ?? 'Unknown';
            var imageUrl = artist['images']?.isNotEmpty == true
                ? artist['images'][0]['url']
                : null;
            var albumName = artist['latest_album']?['name'] ?? 'No album available';
            var topTrackName = artist['top_track']?['name'] ?? 'No track available';
            var previewUrl = artist['top_track']?['preview_url'];
            var spotifyUrl = artist['top_track']?['spotify_url'];
            var followers = artist['followers']?['total'] ?? 'N/A';

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Artist: $artistName',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrl, height: 200, width: 200, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 10),
                    Text('Followers: $followers', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Latest Album: $albumName', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('Top Track: $topTrackName', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    if (previewUrl != null)
                      ElevatedButton(
                        onPressed: () => _playPreview(previewUrl),
                        child: Text(
                          _currentPreviewUrl == previewUrl ? 'Stop Preview' : 'Play Preview',
                        ),
                      ),
                    if (spotifyUrl != null)
                      ElevatedButton(
                        onPressed: () => openSpotifyLink(spotifyUrl),
                        child: const Text('Open in Spotify'),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tilt phone left to like, right to skip!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No artist found"));
          }
        },
      ),
    );
  }
}
