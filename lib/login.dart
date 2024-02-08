import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String username = _usernameController.text.trim();
                  String password = _passwordController.text.trim();

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  List<String>? usernames = prefs.getStringList('usernames');
                  List<String>? passwords = prefs.getStringList('passwords');

                  if (usernames != null && passwords != null && usernames.contains(username)) {
                    int index = usernames.indexOf(username);
                    if (passwords[index] == password) {
                      await prefs.setString('loggedInUser', username);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter Demo Home Page')),
                      );
                    } else {
                      setState(() {
                        _errorMessage = 'Wrong password';
                      });
                    }
                  } else {
                    // Username not found, add it to SharedPreferences
                    usernames ??= [];
                    passwords ??= [];
                    usernames.add(username);
                    passwords.add(password);
                    await prefs.setStringList('usernames', usernames);
                    await prefs.setStringList('passwords', passwords);
                    await prefs.setString('loggedInUser', username);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter Demo Home Page')),
                    );
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
