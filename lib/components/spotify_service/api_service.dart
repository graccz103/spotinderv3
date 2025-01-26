import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> registerUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Dodaj obsługę błędów, aby pokazać użytkownikowi szczegóły problemu
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to register user');
    }
  }


  Future<Map<String, dynamic>> loginUser(String username,
      String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login user');
    }
  }

  Future<Map<String, dynamic>> fetchLists(String userId) async {
    try {
      print('Fetching lists for userId: $userId'); // Loguj ID użytkownika
      final response = await http.get(Uri.parse('$baseUrl/lists/$userId'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch lists');
      }
    } catch (e) {
      print('Error in fetchLists: $e');
      throw e;
    }
  }


  Future<void> updateLikeList(String userId, String artistId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/likelist/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'artistId': artistId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update likelist');
    }
  }

  Future<void> updateHateList(String userId, String artistId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hatelist/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'artistId': artistId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update hatelist');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  Future<void> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }


  Future<void> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete resource');
    }
  }
}