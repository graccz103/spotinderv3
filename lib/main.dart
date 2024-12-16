import 'package:flutter/material.dart';
import 'spotify_service.dart'; // Pamiętaj o zaimportowaniu nowego pliku serwisowego

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Spotinder Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>> artistData;

  @override
  void initState() {
    super.initState();
    artistData = SpotifyService().getArtistData('4Z8W4fKeB5YxbusRsdQVPb'); // Przykładowe ID artysty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: artistData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Name: ${snapshot.data?['name'] ?? 'Unknown'}'),
                  snapshot.data?['images'].isNotEmpty
                      ? Image.network(snapshot.data?['images'][0]['url'])
                      : SizedBox(),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
