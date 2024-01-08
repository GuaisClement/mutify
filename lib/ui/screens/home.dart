// home.dart

import 'package:flutter/material.dart';

import 'song_screen.dart';
// Importez d'autres dépendances nécessaires

class Home extends StatefulWidget {
  const Home({super.key});
  final String title = 'test';

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongScreen(
                songUrls: const [
                  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
                  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
                  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
                ],
                imageUrls: [],
              ),
            ),
          );
        },
        tooltip: 'button',
        child: const Icon(Icons.add),
      ),
    );
  }
}
