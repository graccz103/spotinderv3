import 'package:flutter/material.dart';
import 'dart:math';
import '../../spotify_service.dart';
import '../spotify_service/utils.dart';
import '../spotify_service/api_service.dart';
import 'liked_artists_page.dart';
import 'my_home_page/artist_info_widget.dart';
import 'my_home_page/liked_artists_manager.dart';
import 'my_home_page/accelerometer_listener.dart';
import 'my_home_page/play_preview_button.dart';
import 'hated_artists_page.dart';
import 'my_home_page/hated_artists_manager.dart';
import 'my_home_page/login_page.dart';
import 'my_home_page/register_page.dart';

late ApiService _apiService;
String? _userId; // ID zalogowanego użytkownika
bool get _isLoggedIn => _userId != null;

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
  List<String> genres = []; // Zmienna na listę gatunków
  String? selectedGenre; // Wybrany gatunek
  final PreviewPlayer _previewPlayer = PreviewPlayer();

  double _dragPosition = 0;
  double _rotationAngle = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGenres(); // Załaduj dostępne gatunki
    _loadLikedArtists();
    _loadHatedArtists();
    _apiService = ApiService(baseUrl: 'http://10.0.2.2:4000');
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


  Future<void> _loginOrRegister(String username, String password, bool isLogin) async {
    try {
      final response = isLogin
          ? await _apiService.loginUser(username, password)
          : await _apiService.registerUser(username, password);

      setState(() {
        _userId = response['userId'];
      });

      if (isLogin) {
        await _synchronizeLists(); // Synchronizacja po każdym logowaniu
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? 'Login successful' : 'Registration successful')),
      );
    } catch (e) {
      print('Error in login/register: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? 'Login failed' : 'Registration failed')),
      );
    }
  }




  Future<void> _synchronizeLists() async {
    if (_userId == null) {
      print('User not logged in');
      return;
    }

    try {
      print('Synchronizing lists for userId: $_userId');
      final lists = await _apiService.fetchLists(_userId!);
      print('Fetched lists: $lists');

      setState(() {
        likedArtists = List<Map<String, dynamic>>.from(lists['likelist']);
        hatedArtists = List<Map<String, dynamic>>.from(lists['hatelist']);
      });

      print('Updated likedArtists: $likedArtists');
      print('Updated hatedArtists: $hatedArtists');

      // Zapisz lokalnie
      await LikedArtistsManager.saveLikedArtists(likedArtists);
      await HatedArtistsManager.saveHatedArtists(hatedArtists);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lists synchronized')),
      );
    } catch (e) {
      print('Error synchronizing lists: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to synchronize lists')),
      );
    }
  }





  Future<void> _loadGenres() async {
    genres = widget.spotifyService.getAvailableGenres();
    setState(() {});
  }

  Future<void> _fetchNextArtist() async {
    try {
      var newArtist = await widget.spotifyService.getRandomArtist(
        excludedIds: [
          ...likedArtists.map((artist) => artist['id']),
          ...hatedArtists.map((artist) => artist['id']),
        ],
        genre: selectedGenre,
      );

      // Pobierz szczegóły artysty
      var detailedArtist = await widget.spotifyService.getArtistData(newArtist);

      // Przypisz artystę do danych
      setState(() {
        artistData = Future.value(detailedArtist);
      });
    } catch (e) {
      print('Error fetching artist: $e');
      await Future.delayed(const Duration(seconds: 2));
      _fetchNextArtist();
    }
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
    if (_isLoggedIn) {
      try {
        await _apiService.updateLikeList(_userId!, currentArtist['id']); // Dodaj do likelist w bazie
      } catch (e) {
        print('Failed to update likelist: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add artist to likelist in database')),
        );
      }
    }
    setState(() {
      likedArtists.add(currentArtist); // Dodaj lokalnie
      _saveLikedArtists(); // Zapisz lokalnie
      _resetPosition();
    });
    _fetchNextArtist();
  }

  void _hateCurrentArtist() async {
    var currentArtist = await artistData;
    if (_isLoggedIn) {
      try {
        await _apiService.updateHateList(_userId!, currentArtist['id']); // Dodaj do hatelist w bazie
      } catch (e) {
        print('Failed to update hatelist: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add artist to hatelist in database')),
        );
      }
    }
    setState(() {
      hatedArtists.add(currentArtist); // Dodaj lokalnie
      _saveHatedArtists(); // Zapisz lokalnie
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
          if (_userId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Logged in',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          DropdownButton<String>(
            value: selectedGenre,
            hint: const Text('Select genre'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Genres')),
              ...genres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))),
            ],
            onChanged: (value) {
              if (value == null || widget.spotifyService.validateGenre(value)) {
                setState(() {
                  selectedGenre = value;
                  _fetchNextArtist(); // Przeładuj artystów na podstawie gatunku
                });
              } else {
                print('Invalid genre selected');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              print('Synchronizing lists manually...');
              await _synchronizeLists();
            },
          ),


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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
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
          ),
          // Add the Login and Register buttons at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: !_isLoggedIn
                ? [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        onLogin: (username, password) {
                          _loginOrRegister(username, password, true);
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(
                        onRegister: (username, password) {
                          _loginOrRegister(username, password, false);
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
            ]
                : [
              Center(
                child: Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
