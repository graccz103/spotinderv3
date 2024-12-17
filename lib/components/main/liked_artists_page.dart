import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_home_page/liked_artists_manager.dart';

class LikedArtistsPage extends StatefulWidget {
  final List<Map<String, dynamic>> likedArtists;

  const LikedArtistsPage({Key? key, required this.likedArtists}) : super(key: key);

  @override
  _LikedArtistsPageState createState() => _LikedArtistsPageState();
}

class _LikedArtistsPageState extends State<LikedArtistsPage> {
  List<Map<String, dynamic>> _likedArtists = [];

  @override
  void initState() {
    super.initState();
    _likedArtists = List.from(widget.likedArtists); // Tworzymy kopię listy
  }

  Future<void> _removeArtist(int index) async {
    setState(() {
      _likedArtists.removeAt(index);
    });
    await LikedArtistsManager.saveLikedArtists(_likedArtists);
  }

  Future<void> _openArtistProfile(String spotifyUrl) async {
    if (await canLaunchUrl(Uri.parse(spotifyUrl))) {
      await launchUrl(Uri.parse(spotifyUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $spotifyUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Artists"),
      ),
      body: _likedArtists.isEmpty
          ? const Center(child: Text("No liked artists yet."))
          : ListView.builder(
        itemCount: _likedArtists.length,
        itemBuilder: (context, index) {
          var artist = _likedArtists[index];
          var artistName = artist['name'] ?? 'Unknown';
          var imageUrl = artist['images']?.isNotEmpty == true
              ? artist['images'][0]['url']
              : null;
          var spotifyUrl = artist['external_urls']?['spotify']; // Link do Spotify

          return ListTile(
            leading: imageUrl != null
                ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                : null,
            title: Text(artistName),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeArtist(index),
            ),
            onTap: () {
              if (spotifyUrl != null) {
                _openArtistProfile(spotifyUrl); // Otwórz profil artysty
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Spotify link not available')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
