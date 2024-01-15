// company_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/ui/screens/song_screen.dart';

import '../../blocs/playing_song_cubit.dart';
import '../../blocs/track_cubit.dart';
import '../../models/track.dart';

class TrackListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PlayingSongCubit playingSongCubit =BlocProvider.of<PlayingSongCubit>(context);
    return BlocBuilder<TrackCubit, List<Track>>(
      builder: (context, state) {

        return ListView.separated(
          itemCount: state.length,
          itemBuilder: (BuildContext context, int index) {
            final Track track = state[index];
            return ListTile(
            leading: CircleAvatar(
              backgroundImage: track.imageUrl.isNotEmpty
                  ? NetworkImage(track.imageUrl)
                  : NetworkImage('assets/placeholder_track.webp') as ImageProvider, // Remplacez par une image de remplacement ou un espace réservé
            ),
              title: Text(track.name),
              subtitle: Text(track.artists),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      print("name : " + track.name);
                      print("song url : " + track.previewUrl);
                      Navigator.push(
                        context,
                        MaterialPageRoute(                          
                          builder: (context) {
                            playingSongCubit.updateIndexSong(index);
                            return SongScreen();
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      context.read<TrackCubit>().removeTrack(track.id);
                    },
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(height: 0);
          },
        );
      },
    );
  }
}
