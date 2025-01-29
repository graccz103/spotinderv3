import 'package:flutter/material.dart';
import 'components/main/my_app.dart';
import 'spotify_service.dart';

void main() {
  // Tworzenie instancji SpotifyService z parametrami do potrzebnymi do api
  final spotifyService = SpotifyService(
    clientId: '2ee60615c2704ff2a0f06e3f9207a296',
    clientSecret: 'f2a9203eacd349b3bc9bcc93200a0e28',
  );

  // Uruchomienie
  runApp(MyApp(spotifyService: spotifyService));
}
