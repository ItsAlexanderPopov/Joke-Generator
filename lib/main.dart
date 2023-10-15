import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

/* import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 */
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: SafeArea(
        child: MaterialApp(
          title: 'WordPair Generator',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromRGBO(100, 200, 255, 1)),
          ),
          home: BottomNavBar(),
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  /* late Future<String> futureAlbumString; */
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite(checkCurrent) {
    if (favorites.contains(checkCurrent)) {
      favorites.remove(checkCurrent);
    } else {
      favorites.add(checkCurrent);
    }
    notifyListeners();
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  //
  Widget getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return FavoritesPage();
      default:
        return HomePage();
    }
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define a custom ButtonStyle for the buttons on HomePage
    final ButtonStyle customButtonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.primary,
      ),
      foregroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.onPrimary,
      ),
    );
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: Icon(icon),
                label: Text('Like'),
                style: customButtonStyle,
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                style: customButtonStyle,
                child: Text('Generate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoriteWords = appState.favorites;

    return ListView(
      children: [
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            'Saved Generated Words:',
          ),
        ),
        for (var fav in favoriteWords) SmallCard(pair: fav),
      ],
    );
  }
}

// Homepage's generated words card
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = TextStyle(
      fontSize: 32,
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    // Split the WordPair into words and capitalize each word, then join them with a space in between.
    final words = pair.asPascalCase.split(RegExp(r'(?=[A-Z])'));
    final formattedPair = words.map((word) => word).join(' ');

    return Card(
      color: theme.colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          formattedPair,
          style: style,
        ),
      ),
    );
  }
}

// Favorite Page's cards
class SmallCard extends StatelessWidget {
  final WordPair pair;

  SmallCard({required this.pair});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Card(
      child: ListTile(
        title: Text(
          pair.asPascalCase,
          style: TextStyle(fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                _copyToClipboard(pair.asPascalCase, context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.toggleFavorite(pair);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Copy function
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text copied to clipboard'),
      ),
    );
  }
}

/* Future<String> fetchAlbumAsString() async {
  final response = await http
      .get(Uri.parse('https://v2.jokeapi.dev/joke/Any?format=txt&type=twopart'));

  if (response.statusCode == 200) {
    // If the server returned a 200 OK response,
    // return the response body as a string.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // throw an exception.
    throw Exception('Failed to load album');
  }
}
 */
/* 
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> fetchAlbumAsString() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    // If the server returned a 200 OK response,
    // return the response body as a string.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // throw an exception.
    throw Exception('Failed to load album');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> futureAlbumString;

  @override
  void initState() {
    super.initState();
    futureAlbumString = fetchAlbumAsString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: futureAlbumString,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Text('Data: ${snapshot.data}');
              } else {
                return const Text('No data available');
              }
            },
          ),
        ),
      ),
    );
  }
} */