import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/track_cubit.dart';
import '../../models/track.dart';

class TrackListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackCubit, List<Track>>(
      builder: (context, state) {
        return ListView.separated(
            itemCount: state.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index < state.length) {
                final Track track = state[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: track.imageUrl.isNotEmpty
                        ? NetworkImage(track.imageUrl)
                        : NetworkImage(
                        'assets/placeholder_track.webp') as ImageProvider, // Remplacez par une image de remplacement ou un espace réservé
                  ),
                  title: Text(
                    track.name,
                    style: TextStyle(
                      color: Colors.white, // Couleur du titre (blanc)
                    ),
                  ),
                  subtitle: Text(
                    track.artists,
                    style: TextStyle(
                      color: Colors
                          .grey[500], // Couleur du sous-titre (blanc grisé)
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () {
                          context.read<TrackCubit>().removeTrack(track.id);
                        },
                      ),
                    ],
                  ),
                );
              }else{
                // Ajouter le Container après le dernier ListTile
                return Container(
                  height: 60.0,
                  width: double.infinity,
                  color: Colors.transparent,
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0);
            },
        );
      },
    );
  }
}
