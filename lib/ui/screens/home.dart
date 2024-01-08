// home.dart

import 'package:flutter/material.dart';
import 'package:mutify/ui/screens/artist_list_view.dart';
import 'package:mutify/ui/screens/search_track_artist.dart';
import 'package:mutify/ui/screens/track_artist_list_view.dart';
// Importez d'autres dépendances nécessaires

class Home extends StatefulWidget {
  const Home({super.key});
  final String title = 'Mutify';

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _currentIndex = 0;


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
      body: _currentIndex == 0
          ? TrackListView()
          : _currentIndex == 1
              ? ArtistListView()
              : const SearchTrackArtist(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music_rounded),
            label: 'Tracks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account_rounded),
            label: 'Artistes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Rechercher',
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
