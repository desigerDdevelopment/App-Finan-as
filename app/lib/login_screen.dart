import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveUser() async {
    if (_nameController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _nameController.text);
      await prefs.setDouble('saldo', 1518.0);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(username: _nameController.text),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Usuário")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Digite seu nome para começar:"),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUser,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
