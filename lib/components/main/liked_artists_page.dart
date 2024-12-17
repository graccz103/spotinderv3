import 'package:flutter/material.dart';

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
