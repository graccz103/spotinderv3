import 'package:flutter/material.dart';
import '../../spotify_service.dart';
import 'my_home_page.dart';

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
