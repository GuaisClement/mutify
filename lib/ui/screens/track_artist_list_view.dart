// company_list_view.dart

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/ui/screens/song_screen.dart';

import '../../blocs/track_cubit.dart';
import '../../models/track.dart';

class TrackListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackCubit, List<Track>>(
      builder: (context, state) {
        List<String> imageUrls = state.map((track) => track.imageUrl).toList();
        List<String> songUrls = state.map((track) {
          // Check if previewUrl is not null or empty, otherwise set it to "not found"
          return (track.previewUrl != null && track.previewUrl.isNotEmpty)
              ? track.previewUrl
              : "not found";
        }).toList();

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
                            return SongScreen(
                              songUrls: songUrls,
                              imageUrls: imageUrls,
                              indexSong: index ,
                            );                            
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
