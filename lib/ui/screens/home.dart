import 'package:flutter/material.dart';
import 'package:mutify/ui/screens/artist_list_view.dart';
import 'package:mutify/ui/screens/search_track_artist.dart';
import 'package:mutify/ui/screens/track_list_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  final String title = 'Mutify';

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF003366),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF003366), Colors.black],
              ),
            ),
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                TrackListView(),
                ArtistListView(),
                const SearchTrackArtist(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(1),
                  ],
                ),
              ),
              child: _buildBottomNavigationBar(),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          _pageController.jumpToPage(
            index
          );
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.queue_music_rounded,
          ),
          label: 'Tracks',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.supervisor_account_rounded,
          ),
          label: 'Artistes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
          ),
          label: 'Rechercher',
        ),
      ],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[500],
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: Colors.transparent,
    );
  }
}


