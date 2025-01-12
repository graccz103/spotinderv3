import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_home_page/hated_artists_manager.dart';
import '../spotify_service/api_service.dart';

class HatedArtistsPage extends StatefulWidget {
  final List<Map<String, dynamic>> hatedArtists;
  final String userId;

  const HatedArtistsPage({Key? key, required this.hatedArtists, required this.userId}) : super(key: key);


  @override
  _HatedArtistsPageState createState() => _HatedArtistsPageState();
}

class _HatedArtistsPageState extends State<HatedArtistsPage> {
  late List<Map<String, dynamic>> _hatedArtists;

  @override
  void initState() {
    super.initState();
    _hatedArtists = List.from(widget.hatedArtists);
  }

  Future<void> _removeArtist(int index) async {
    var artist = _hatedArtists[index];
    try {
      await ApiService(baseUrl: 'http://10.0.2.2:4000')
          .delete('/hatelist/${widget.userId}/${artist['id']}');
      setState(() {
        _hatedArtists.removeAt(index);
      });
      await HatedArtistsManager.saveHatedArtists(_hatedArtists);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove artist from database: $e')),
      );
    }
  }




  Future<void> _openArtistProfile(String spotifyUrl) async {
    if (await canLaunchUrl(Uri.parse(spotifyUrl))) {
      await launchUrl(Uri.parse(spotifyUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Spotify link')),
      );
    }
  }

  void _onBackPressed() {
    Navigator.pop(context, _hatedArtists);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Hated Artists"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
        ),
        body: _hatedArtists.isEmpty
            ? const Center(child: Text("No hated artists yet."))
            : ListView.builder(
          itemCount: _hatedArtists.length,
          itemBuilder: (context, index) {
            var artist = _hatedArtists[index];
            var artistName = artist['name'] ?? 'Unknown';
            var imageUrl = artist['images']?.isNotEmpty == true
                ? artist['images'][0]['url']
                : null;
            var spotifyUrl = artist['external_urls']?['spotify'];

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
                  _openArtistProfile(spotifyUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spotify link not available')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
