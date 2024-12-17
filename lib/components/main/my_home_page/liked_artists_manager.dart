import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LikedArtistsManager {
  static Future<void> saveLikedArtists(List<Map<String, dynamic>> likedArtists) async {
    final prefs = await SharedPreferences.getInstance();
    final likedArtistsJson = jsonEncode(likedArtists);
    await prefs.setString('likedArtists', likedArtistsJson);
  }

  static Future<List<Map<String, dynamic>>> loadLikedArtists() async {
    final prefs = await SharedPreferences.getInstance();
    final likedArtistsJson = prefs.getString('likedArtists');
    if (likedArtistsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(likedArtistsJson));
    }
    return [];
  }
}
