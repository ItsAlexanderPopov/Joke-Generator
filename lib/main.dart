import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'data_fetcher_service.dart';

void main() {
  final dataService = DataService(
    'https://v2.jokeapi.dev/joke/Programming,Pun,Spooky,Christmas?blacklistFlags=nsfw,political,racist,sexist,explicit&type=twopart',
  );

  dataService.fetchData().then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => dataService,
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: SafeArea(
        child: MaterialApp(
          title: 'Joke Generator',
          theme: ThemeData(
            primarySwatch: Colors.yellow,
          ),
          home: BottomNavBar(),
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var favorites = <Map<String, String>>[];

  void toggleFavorite(String? setup, String? delivery) {
    // Check if any map in favorites has the same "setup" value
    final index = favorites.indexWhere((fav) => fav['setup'] == setup);

    if (index >= 0) {
      // If found, remove it
      favorites.removeAt(index);
    } else {
      // If not found, add a new map
      favorites.add({'setup': setup ?? '', 'delivery': delivery ?? ''});
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
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
      fixedSize: MaterialStateProperty.all(
        Size(150, 50),
      ),
    );

    var appState = context.watch<MyAppState>();
    final dataService = context.watch<DataService>();

    IconData icon;
    if (appState.favorites.any((fav) => fav['setup'] == dataService.setup)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BigCard(
            setup: dataService.setup.toString(),
            delivery: dataService.delivery.toString(),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 20,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(
                      dataService.setup, dataService.delivery);
                },
                icon: Icon(icon),
                label: Text('Like'),
                style: customButtonStyle,
              ),
              ElevatedButton(
                onPressed: () {
                  dataService.refreshData();
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
        for (var fav in favoriteWords)
          SmallCard(
            setup: fav['setup'] ?? '',
            delivery: fav['delivery'] ?? '',
          ),
      ],
    );
  }
}

// Homepage's generated joke cards
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.setup,
    required this.delivery,
  }) : super(key: key);

  final String setup;
  final String delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = TextStyle(
      fontSize: 24,
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        Card(
          color: theme.colorScheme.onPrimary,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              setup,
              style: style,
            ),
          ),
        ),
        Card(
          color: theme.colorScheme.onPrimary,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              delivery,
              style: style,
            ),
          ),
        ),
      ],
    );
  }
}

// Favorite Page's cards
class SmallCard extends StatelessWidget {
  final String setup;
  final String delivery;

  SmallCard({required this.setup, required this.delivery});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var joke = '$setup\n$delivery';
    return Card(
      child: ListTile(
        title: Text(
          joke,
          style: TextStyle(fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                _copyToClipboard(joke, context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.toggleFavorite(setup, delivery);
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
