// company_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/blocs/artist_cubit.dart';

import '../../blocs/track_cubit.dart';
import '../../models/artist.dart';
import '../../models/track.dart';

class ArtistListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistCubit, List<Artist>>(
      builder: (context, state) {
        return ListView.separated(
          itemCount: state.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < state.length) {
              final Artist artist = state[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: artist.imageUrl.isNotEmpty
                      ? NetworkImage(artist.imageUrl)
                      : NetworkImage(
                      'assets/placeholder_track.webp') as ImageProvider, // Remplacez par une image de remplacement ou un espace réservé
                ),
                title: Text(
                    artist.name,
                    style: TextStyle(
                      color: Colors.white, // Couleur du titre (blanc)
                    )
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                          Icons.delete,
                          color: Colors.white),
                      onPressed: () {
                        context.read<ArtistCubit>().removeArtist(artist.id);
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
