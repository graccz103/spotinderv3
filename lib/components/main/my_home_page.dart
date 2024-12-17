import 'package:flutter/material.dart';
import 'dart:math'; // Do obrotu
import '../../spotify_service.dart';
import '../spotify_service/utils.dart';
import 'liked_artists_page.dart';
import 'my_home_page/artist_info_widget.dart';
import 'my_home_page/liked_artists_manager.dart';
import 'my_home_page/accelerometer_listener.dart';
import 'my_home_page/play_preview_button.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final SpotifyService spotifyService;

  const MyHomePage({Key? key, required this.title, required this.spotifyService})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Future<Map<String, dynamic>> artistData = Future.value({}); // Inicjalizacja pustą wartością
  List<Map<String, dynamic>> likedArtists = [];
  final PreviewPlayer _previewPlayer = PreviewPlayer();

  double _dragPosition = 0; // Do przesunięcia
  double _rotationAngle = 0; // Do obrotu

  @override
  void initState() {
    super.initState();
    _loadLikedArtists();
    _fetchNextArtist(); // Pierwsze załadowanie artysty
    listenToAccelerometer(_likeCurrentArtist, _nextArtist);
  }

  Future<void> _fetchNextArtist() async {
    artistData = widget.spotifyService.getRandomArtist(
      excludedIds: likedArtists.map((artist) => artist['id'].toString()).toList(),
    );
    setState(() {}); // Odświeżenie widoku
  }

  Future<void> _loadLikedArtists() async {
    likedArtists = await LikedArtistsManager.loadLikedArtists();
    setState(() {});
  }

  Future<void> _saveLikedArtists() async {
    await LikedArtistsManager.saveLikedArtists(likedArtists);
  }

  void _likeCurrentArtist() async {
    var currentArtist = await artistData;
    setState(() {
      likedArtists.add(currentArtist);
      _saveLikedArtists();
      _resetPosition();
    });
    _fetchNextArtist(); // Załaduj nowego artystę
  }

  void _nextArtist() {
    _fetchNextArtist(); // Załaduj nowego artystę
    _resetPosition();
  }

  void _resetPosition() {
    setState(() {
      _dragPosition = 0;
      _rotationAngle = 0;
    });
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
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
            onPressed: () async {
              var updatedLikedArtists = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedArtistsPage(likedArtists: likedArtists),
                ),
              );

              if (updatedLikedArtists != null) {
                setState(() {
                  likedArtists = updatedLikedArtists; // Aktualizacja lokalnej listy
                });
                await LikedArtistsManager.saveLikedArtists(likedArtists);
              }
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
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _dragPosition += details.delta.dx;
                  _rotationAngle = _dragPosition / 300;
                });
              },
              onPanEnd: (details) {
                if (_dragPosition > 150) {
                  _likeCurrentArtist();
                } else if (_dragPosition < -150) {
                  _nextArtist();
                } else {
                  _resetPosition();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..translate(_dragPosition, 0, 0)
                  ..rotateZ(_rotationAngle * pi / 12),
                child: ArtistInfoWidget(
                  artist: snapshot.data!,
                  currentPreviewUrl: _previewPlayer.currentPreviewUrl,
                  onPlayPreview: (url) => _previewPlayer.playPreview(url, (state) {
                    setState(() {
                      _previewPlayer.currentPreviewUrl = state;
                    });
                  }),
                  onOpenSpotify: openSpotifyLink,
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
