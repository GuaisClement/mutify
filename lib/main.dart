import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/blocs/artist_cubit.dart';
import 'package:mutify/blocs/playing_song_cubit.dart';
import 'package:mutify/repositories/artist_repository.dart';
import 'package:mutify/repositories/track_repository.dart';
import 'package:mutify/ui/screens/home.dart';
import 'package:provider/provider.dart';

import 'blocs/track_cubit.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  final TrackCubit trackCubit = TrackCubit(TrackRepository());
  final ArtistCubit artistCubit = ArtistCubit(ArtistRepository());

  // Chargement des tracks et artists
  trackCubit.loadTracks();
  artistCubit.loadArtists();

  runApp(
      MultiProvider(
          providers: [
            BlocProvider<TrackCubit>(create: (_) => trackCubit),
            BlocProvider<ArtistCubit>(create: (_) => artistCubit),
            BlocProvider<PlayingSongCubit>(create: (_) =>  PlayingSongCubit()),
          ],
        child: const MyApp(),
      )
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Mutify',
      routes: {
        '/home': (context) => Home(),
        //'/': (context) => SongScreen()
      },
      initialRoute: '/home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}


