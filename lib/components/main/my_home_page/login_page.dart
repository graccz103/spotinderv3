import 'package:flutter/material.dart';
import '../../spotify_service/api_service.dart';

class LoginPage extends StatelessWidget {
  final Function(String username, String password) onLogin;

  const LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onLogin(
                  usernameController.text,
                  passwordController.text,
                );
                Navigator.pop(context); // Powrót do głównego widoku
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
