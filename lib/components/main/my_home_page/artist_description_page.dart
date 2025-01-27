import 'package:flutter/material.dart';

class ArtistDescriptionPage extends StatelessWidget {
  final Map<String, dynamic> artist;

  const ArtistDescriptionPage({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var artistName = artist['name'] ?? 'Unknown';
    var imageUrl = artist['images']?.isNotEmpty == true ? artist['images'][0]['url'] : null;
    var description = artist['description'] ?? 'No description available.';

    return Scaffold(
      appBar: AppBar(
        title: Text(artistName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl, height: 300, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            Text(
              artistName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
