import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'colors.dart';
import 'data_fetcher_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = MyAppState();
  await SharedPreferences.getInstance();
  await appState.loadFavorites();

  final dataService = DataService(
    'https://v2.jokeapi.dev/joke/Programming,Pun,Spooky,Christmas?blacklistFlags=nsfw,political,racist,sexist,explicit&type=twopart',
  );

  dataService.fetchData().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => appState),
          ChangeNotifierProvider(create: (_) => dataService),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.backgroundColor,
    );

    return ChangeNotifierProvider.value(
      value: context.read<MyAppState>(),
      child: SafeArea(
        child: MaterialApp(
          title: 'Joke Generator',
          theme: customTheme,
          home: BottomNavBar(),
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var favorites = <Map<String, String>>[];

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = favorites.map((fav) => fav).toList();
    await prefs.setString('favorites', jsonEncode(favoritesJson));
  }

  Future<void> loadFavorites() async {
    favorites = <Map<String, String>>[];
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final favoritesList = (jsonDecode(favoritesJson) as List?);
      if (favoritesList != null) {
        favorites = favoritesList.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      }
    }
    notifyListeners();
  }

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
    saveFavorites();
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
        backgroundColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightColor,
        selectedItemColor: AppColors.secondaryColor,
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
        AppColors.primaryColor,
      ),
      foregroundColor: MaterialStateProperty.all(
        AppColors.secondaryColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 50),
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
              SizedBox(height: 100),
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
          height: 20,
        ),
        Center(
          child: Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.lightColor,
            ),
            'Favorite Jokes:',
          ),
        ),
        SizedBox(
          height: 20,
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
    final style = GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 24,
        color: AppColors.backgroundColor,
        fontWeight: FontWeight.bold,
      ),
    );

    return Column(
      children: [
        Card(
          color: AppColors.lightColor,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              setup,
              style: style,
            ),
          ),
        ),
        Card(
          color: AppColors.lightColor,
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
    var joke = '$setup\n\n$delivery';
    final style = GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 14,
        color: AppColors.backgroundColor,
        fontWeight: FontWeight.bold,
      ),
    );

    return Card(
      color: AppColors.lightColor,
      child: ListTile(
        title: Text(
          joke,
          style: style,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                _copyToClipboard(joke, context);
              },
              color: AppColors.backgroundColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.toggleFavorite(setup, delivery);
              },
              color: AppColors.backgroundColor,
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
