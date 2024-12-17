import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String clientId;
  final String clientSecret;

  AuthService({required this.clientId, required this.clientSecret});

  Future<String> getAccessToken() async {
    var response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body:
      'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret',
    );

    var data = jsonDecode(response.body);
    return data['access_token'];
  }
}
