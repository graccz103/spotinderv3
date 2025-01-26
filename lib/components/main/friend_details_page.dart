import 'package:flutter/material.dart';

class FriendDetailsPage extends StatelessWidget {
  final Map<String, dynamic> friend;

  const FriendDetailsPage({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(friend['username'])),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Liked Artists',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: friend['likelist'].isEmpty
                ? const Center(child: Text('No liked artists.'))
                : ListView.builder(
              itemCount: friend['likelist'].length,
              itemBuilder: (context, index) {
                final artist = friend['likelist'][index];
                return ListTile(
                  leading: artist['images']?.isNotEmpty == true
                      ? Image.network(
                    artist['images'][0]['url'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image_not_supported),
                  title: Text(artist['name'] ?? 'Unknown'),
                );
              },
            ),
          ),
          const Divider(),
          const Text(
            'Hated Artists',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: friend['hatelist'].isEmpty
                ? const Center(child: Text('No hated artists.'))
                : ListView.builder(
              itemCount: friend['hatelist'].length,
              itemBuilder: (context, index) {
                final artist = friend['hatelist'][index];
                return ListTile(
                  leading: artist['images']?.isNotEmpty == true
                      ? Image.network(
                    artist['images'][0]['url'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image_not_supported),
                  title: Text(artist['name'] ?? 'Unknown'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
