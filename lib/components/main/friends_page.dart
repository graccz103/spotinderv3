import 'package:flutter/material.dart';
import '../spotify_service/api_service.dart';
import 'friend_details_page.dart';

class FriendsPage extends StatefulWidget {
  final String userId;

  const FriendsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _users = [];
  final ApiService _apiService = ApiService(baseUrl: 'http://10.0.2.2:4000');

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _fetchAllUsers();
  }

  Future<void> _fetchFriends() async {
    try {
      final friends = await _apiService.get('/friends/${widget.userId}');
      setState(() {
        _friends = List<Map<String, dynamic>>.from(friends);
      });
      _filterAvailableUsers(); // Odśwież listę użytkowników
    } catch (e) {
      print('Failed to fetch friends: $e');
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      final users = await _apiService.get('/users/${widget.userId}');
      setState(() {
        _users = List<Map<String, dynamic>>.from(users);
      });
      _filterAvailableUsers(); // Odśwież listę użytkowników
    } catch (e) {
      print('Failed to fetch users: $e');
    }
  }

  void _filterAvailableUsers() {
    setState(() {
      // Usuń użytkowników, którzy są już znajomymi
      _users = _users.where((user) {
        return !_friends.any((friend) => friend['id'] == user['_id']);
      }).toList();
    });
  }

  Future<void> _addFriend(String friendId) async {
    try {
      await _apiService.post('/friends/${widget.userId}', {'friendId': friendId});
      _fetchFriends(); // Odśwież listę znajomych
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully')),
      );
    } catch (e) {
      print('Failed to add friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add friend')),
      );
    }
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      await _apiService.delete('/friends/${widget.userId}/$friendId');
      setState(() {
        _friends.removeWhere((friend) => friend['id'] == friendId);
      });
      _filterAvailableUsers(); // Zaktualizuj listę użytkowników
    } catch (e) {
      print('Failed to remove friend: $e');
    }
  }

  void _viewFriendDetails(Map<String, dynamic> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendDetailsPage(friend: friend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Column(
        children: [
          Expanded(
            child: _friends.isEmpty
                ? const Center(child: Text('No friends yet.'))
                : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  title: Text(friend['username']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFriend(friend['id']),
                  ),
                  onTap: () => _viewFriendDetails(friend),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _users.isEmpty
                ? const Center(child: Text('No users available to add.'))
                : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['username']),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.green),
                    onPressed: () => _addFriend(user['_id']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
