import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  runApp(MyApp(username: username));
}

class MyApp extends StatelessWidget {
  final String? username;
  const MyApp({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: username == null ? const LoginScreen() : HomeScreen(username: username!),
    );
  }
}
