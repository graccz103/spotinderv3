import 'package:flutter/material.dart';
import 'dart:math';
import '../../spotify_service.dart';
import '../spotify_service/utils.dart';
import 'liked_artists_page.dart';
import 'my_home_page/artist_info_widget.dart';
import 'my_home_page/liked_artists_manager.dart';
import 'my_home_page/accelerometer_listener.dart';
import 'my_home_page/play_preview_button.dart';
import 'hated_artists_page.dart';
import 'my_home_page/hated_artists_manager.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final SpotifyService spotifyService;

  const MyHomePage({Key? key, required this.title, required this.spotifyService})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Future<Map<String, dynamic>> artistData = Future.value({});
  List<Map<String, dynamic>> likedArtists = [];
  List<Map<String, dynamic>> hatedArtists = [];
  final PreviewPlayer _previewPlayer = PreviewPlayer();

  double _dragPosition = 0;
  double _rotationAngle = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLikedArtists();
    _loadHatedArtists();
    _fetchNextArtist();
    AccelerometerListener.startListening(_likeCurrentArtist, _hateCurrentArtist);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AccelerometerListener.stopListening();
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AccelerometerListener.stopListening();
    } else if (state == AppLifecycleState.resumed) {
      AccelerometerListener.startListening(_likeCurrentArtist, _hateCurrentArtist);
    }
  }

  Future<void> _fetchNextArtist() async {
    artistData = widget.spotifyService.getRandomArtist(
      excludedIds: [
        ...likedArtists.map((artist) => artist['id']),
        ...hatedArtists.map((artist) => artist['id']),
      ],
    );
    setState(() {});
  }

  Future<void> _loadLikedArtists() async {
    likedArtists = await LikedArtistsManager.loadLikedArtists();
    setState(() {});
  }

  Future<void> _loadHatedArtists() async {
    hatedArtists = await HatedArtistsManager.loadHatedArtists();
    setState(() {});
  }

  Future<void> _saveLikedArtists() async {
    await LikedArtistsManager.saveLikedArtists(likedArtists);
  }

  Future<void> _saveHatedArtists() async {
    await HatedArtistsManager.saveHatedArtists(hatedArtists);
  }

  void _likeCurrentArtist() async {
    var currentArtist = await artistData;
    setState(() {
      likedArtists.add(currentArtist);
      _saveLikedArtists();
      _resetPosition();
    });
    _fetchNextArtist();
  }

  void _hateCurrentArtist() async {
    var currentArtist = await artistData;
    setState(() {
      hatedArtists.add(currentArtist);
      _saveHatedArtists();
      _resetPosition();
    });
    _fetchNextArtist();
  }

  void _resetPosition() {
    setState(() {
      _dragPosition = 0;
      _rotationAngle = 0;
    });
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
                  likedArtists = updatedLikedArtists;
                });
                await _saveLikedArtists();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              var updatedHatedArtists = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HatedArtistsPage(hatedArtists: hatedArtists),
                ),
              );

              if (updatedHatedArtists != null) {
                setState(() {
                  hatedArtists = updatedHatedArtists;
                });
                await _saveHatedArtists();
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
                  _hateCurrentArtist();
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
