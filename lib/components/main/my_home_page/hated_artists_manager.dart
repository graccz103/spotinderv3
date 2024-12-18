import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HatedArtistsManager {
  static Future<void> saveHatedArtists(List<Map<String, dynamic>> hatedArtists) async {
    final prefs = await SharedPreferences.getInstance();
    final hatedArtistsJson = jsonEncode(hatedArtists);
    await prefs.setString('hatedArtists', hatedArtistsJson);
  }

  static Future<List<Map<String, dynamic>>> loadHatedArtists() async {
    final prefs = await SharedPreferences.getInstance();
    final hatedArtistsJson = prefs.getString('hatedArtists');
    if (hatedArtistsJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(hatedArtistsJson));
    }
    return [];
  }
}
