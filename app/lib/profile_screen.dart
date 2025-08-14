import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final double salary;

  const ProfileScreen({super.key, required this.username, required this.salary});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
    _salaryController = TextEditingController(text: widget.salary.toStringAsFixed(2));
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nameController.text);
    await prefs.setDouble('salary', double.tryParse(_salaryController.text) ?? widget.salary);
    await prefs.setDouble('saldo', double.tryParse(_salaryController.text) ?? widget.salary);

    Navigator.pop(context, {
      "username": _nameController.text,
      "salary": double.tryParse(_salaryController.text) ?? widget.salary
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Salário Mensal"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
