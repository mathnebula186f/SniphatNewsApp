import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'homepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? loggedInUser = prefs.getString('loggedInUser');
  try {
    await dotenv.load(fileName: '.env');

  } catch (e) {
    print('Error loading environment variables: $e');
  }

  runApp(MyApp(loggedInUser: loggedInUser));
}

class MyApp extends StatelessWidget {
  final String? loggedInUser;

  const MyApp({Key? key, this.loggedInUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: loggedInUser == null ? LoginPage() : MyHomePage(title: 'News Page'),
    );
  }
}
