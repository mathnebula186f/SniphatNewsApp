import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Article {
  final String title;
  final String description;
  bool read;

  Article({
    required this.title,
    required this.description,
    this.read = false, // Assign a default value
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      read: false, // Use a default value if 'read' is null
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Article> _articles = [];
  List<Article> _filteredArticles = []; // List to hold filtered articles

  @override
  void initState() {
    super.initState();
    checkLoggedInUser();
  }


  Future<void> checkLoggedInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUser = prefs.getString('loggedInUser');
    if (loggedInUser == null) {
      // If no logged-in user found, navigate to login page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      // Fetch news only if logged-in user is present
      fetchNews();
    }
  }

  Future<void> fetchNews() async {

    final String apiKey = '5db210623f3a45e59279adff8a854893';
    print("here si the apikey=$apiKey");
    final String url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> articles = data['articles'];

      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        _articles = articles.map((article) => Article.fromJson(article)).toList();

        // Initialize filtered articles with all articles
        _filteredArticles = List.from(_articles);

        // Iterate over filtered articles and update flags based on SharedPreferences
        _filteredArticles.forEach((filteredArticle) {
          // Check if article is marked as read
          if (prefs.containsKey(filteredArticle.title)) {
            filteredArticle.read = prefs.getBool(filteredArticle.title) ?? false;
          }
          // Check if article is deleted
          if (prefs.containsKey('deleted_${filteredArticle.title}')) {
            _filteredArticles.remove(filteredArticle);
          }
        });
      });
    } else {
      print("Failed to load news");
      throw Exception('Failed to load news');
    }
  }


  Future<void> markAsRead(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _articles[index].read = true;
      _filteredArticles[index].read = true;
      prefs.setBool(_articles[index].title, true); // Save article as read in SharedPreferences
      prefs.setBool(_filteredArticles[index].title, true); // Save article as read in SharedPreferences
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loggedInUser');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> deleteArticle(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _articles.removeAt(index);
      _filteredArticles = List.from(_articles); // Update filtered articles after deletion
      prefs.remove(_filteredArticles[index].title); // Remove article from SharedPreferences
    });
  }

  void searchArticles(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredArticles = _articles
            .where((article) => article.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredArticles = List.from(_articles); // Show all articles if query is empty
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final String? result = await showSearch(
                context: context,
                delegate: ArticleSearchDelegate(_articles),
              );
              if (result != null) {
                searchArticles(result);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: _filteredArticles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Please Refresh if Nothing Comes up", style: TextStyle(fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _filteredArticles.length,
        itemBuilder: (context, index) {
          return Container(
            color: _filteredArticles[index].read ? Colors.green.withOpacity(0.2) : Colors.transparent,
            child: ListTile(
              leading: Text('${index + 1}'),
              title: Text(
                _filteredArticles[index].title,
                style: TextStyle(color: _filteredArticles[index].read ? Colors.green : Colors.black),
              ),
              subtitle: Text(_filteredArticles[index].description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () => markAsRead(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteArticle(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchNews();
        },
        tooltip: 'Reload',
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class ArticleSearchDelegate extends SearchDelegate<String> {
  final List<Article> articles;

  ArticleSearchDelegate(this.articles);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(); // No need to implement, since results are displayed within the home page
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Article> suggestionList = query.isEmpty
        ? articles
        : articles.where((article) => article.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].title),
          onTap: () {
            close(context, suggestionList[index].title);
          },
        );
      },
    );
  }
}
