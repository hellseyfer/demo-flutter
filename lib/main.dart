import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// The code in MyApp sets up the whole app. It creates the app-wide state, names the app,
//defines the visual theme, and sets the "home" widget—the starting point of your app.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class HeroCard {
  final WordPair name;
  final String imageURL;

  HeroCard(this.name, this.imageURL);
}

final List<String> randomImages = [
  "https://picsum.photos/300/200",
  "https://picsum.photos/300/200",
  "https://picsum.photos/400/300",
  "https://picsum.photos/500/400",
  "https://picsum.photos/600/400",
  "https://picsum.photos/700/500",
  "https://picsum.photos/800/600",
  "https://picsum.photos/900/700",
  "https://picsum.photos/1000/800",
  "https://picsum.photos/1200/900"
];

// There are many powerful ways to manage app state in Flutter. One of the easiest to explain is ChangeNotifier
// The state class extends ChangeNotifier, which means that it can notify others about its own changes
// The state is created and provided to the whole app using a ChangeNotifierProvider
// MyAppState defines the data the app needs to function
// this can grow rapidly, so consider using stateful widgets to manage the state of individual widgets
class MyAppState extends ChangeNotifier {
  HeroCard current = HeroCard(WordPair.random(),
      randomImages[Random().nextInt(randomImages.length)]); //WordPair.random();

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = HeroCard(
        WordPair.random(),
        randomImages[
            Random().nextInt(randomImages.length)]); //WordPair.random();
    notifyListeners(); // ensures that anyone watching MyAppState is notified
  }

  var favorites = <HeroCard>{};

  void toggleFavorite([HeroCard? hero]) {
    var curr = hero ?? current;
    if (favorites.contains(curr)) {
      favorites.remove(curr);
    } else {
      favorites.add(curr);
    }
    notifyListeners();
  }

  void removeFavorite(current) {
    favorites.remove(current);
    notifyListeners();
  }

  var history = <HeroCard>[];
  GlobalKey? historyListKey;
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // state objects here
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              // The SafeArea ensures that its child is not obscured by a hardware notch or a status bar
              child: NavigationRail(
                // wraps around NavigationRail to prevent the navigation buttons from being obscured by a mobile status bar
                extended: constraints.maxWidth >=
                    600, // Two Expanded widgets split all the available horizontal space between themselves
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  // Change state value
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ' '${appState.favorites.length}' ' favorites.'),
        ),
        for (var f in appState.favorites)
          ListTile(
              title: Text(f.name.asPascalCase),
              trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    context.read<MyAppState>().removeFavorite(f);
                  }))
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var hero = appState.current;

    IconData icon;
    if (appState.favorites
        .where((element) => element.name == hero.name)
        .isNotEmpty) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: HistoryListView()),
          SizedBox(height: 10),
          CardWidget(hero: hero),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.hero,
    this.isSmall = false,
  });

  final HeroCard hero;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isSmall
        ? theme.textTheme.titleLarge!.copyWith(
            // Calling copyWith() on displayMedium returns a copy of the text style with the specified changes.
            color: theme.colorScheme.onPrimary)
        : theme.textTheme.displaySmall!.copyWith(
            // Calling copyWith() on displayMedium returns a copy of the text style with the specified changes.
            color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      elevation: 7,
      child: SizedBox(
        height: 400,
        width: 250,
        child: Padding(
            // We've used refactor to add this padding to Text. Padding is a widget itself.
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(child: Image.network(hero.imageURL)),
                Text(
                  hero.name.asLowerCase,
                  style: style,
                  semanticsLabel: "${hero.name.first} ${hero.name.second}",
                ),
              ],
            )),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
      // This gradient goes from fully transparent to fully opaque black...
      colors: [Colors.transparent, Colors.black],
      // ... from the top (transparent) to half (0.5) of the way to the bottom.
      stops: [0.0, 0.9],
      begin: Alignment.centerLeft, //Alignment.topCenter,
      end: Alignment.centerRight // Alignment.bottomCenter,
      );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        scrollDirection: Axis.horizontal, // Axis.vertical
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final hero = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: CardWidget(hero: hero, isSmall: true),
            ),
          );
        },
      ),
    );
  }
}
