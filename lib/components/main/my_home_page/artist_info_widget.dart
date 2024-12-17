import 'package:flutter/material.dart';

class ArtistInfoWidget extends StatelessWidget {
  final Map<String, dynamic> artist;
  final String? currentPreviewUrl;
  final Function(String) onPlayPreview;
  final Function(String) onOpenSpotify;

  const ArtistInfoWidget({
    Key? key,
    required this.artist,
    required this.currentPreviewUrl,
    required this.onPlayPreview,
    required this.onOpenSpotify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var artistName = artist['name'] ?? 'Unknown';
    var imageUrl = artist['images']?.isNotEmpty == true ? artist['images'][0]['url'] : null;
    var albumName = artist['latest_album']?['name'] ?? 'No album available';
    var topTrackName = artist['top_track']?['name'] ?? 'No track available';
    var previewUrl = artist['top_track']?['preview_url'];
    var spotifyUrl = artist['top_track']?['spotify_url'];
    var followers = artist['followers']?['total'] ?? 'N/A';

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            Text('Top Track: $topTrackName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            if (previewUrl != null)
              ElevatedButton(
                onPressed: () => onPlayPreview(previewUrl),
                child: Text(currentPreviewUrl == previewUrl ? 'Stop Preview' : 'Play Preview'),
              ),
            if (spotifyUrl != null)
              ElevatedButton(
                onPressed: () => onOpenSpotify(spotifyUrl),
                child: const Text('Open in Spotify'),
              ),
          ],
        ),
      ),
    );
  }
}
