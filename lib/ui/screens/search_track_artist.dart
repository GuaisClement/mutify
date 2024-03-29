import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/models/artist.dart';
import 'package:mutify/models/track.dart';
import 'package:mutify/repositories/artist_repository.dart';

import '../../blocs/artist_cubit.dart';
import '../../blocs/track_cubit.dart';
import '../../repositories/track_repository.dart';

class SearchTrackArtist extends StatefulWidget {
  const SearchTrackArtist({super.key});

  @override
  State<SearchTrackArtist> createState() => _SearchTrackArtistState();
}

class _SearchTrackArtistState extends State<SearchTrackArtist> {

  List<Track> _tracks = [];
  List<Artist> _artists = [];
  Timer? _debounceTimer;


  TextEditingController _searchController = TextEditingController();
  String _selectedSearchType = 'Titre';


  TrackRepository _trackRepository = TrackRepository();
  ArtistRepository _artistRepository = ArtistRepository();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            height: 70,
            child: TextField(
              controller: _searchController,
              onChanged: (query) {

                // Annulez le délai précédent si l'utilisateur continue de taper
                if (query.length > 2) {
                  if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

                  // Démarrez un nouveau délai de 500 ms
                  _debounceTimer = Timer(Duration(milliseconds: 500), () {

                    if(_selectedSearchType == 'Titre'){
                      updateTracks(query);
                    }else{
                      updateArtists(query);
                    }
                  });
                }
              },
              decoration: InputDecoration(
                hintText: _selectedSearchType == 'Titre' ? 'Rechercher une musique' : 'Rechecher un artiste',
                prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Container(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _selectedSearchType = 'Titre';
                    });
                  },
                  child: Row(
                    children: [
                      Radio(
                        value: 'Titre',
                        groupValue: _selectedSearchType,
                        onChanged: (String? newValue) {
                          // Aucune action nécessaire ici, car l'action est gérée par l'InkWell
                        },
                        activeColor: Colors.white, // Couleur du cercle du bouton radio quand il est sélectionné
                      ),
                      Text('Titre', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _selectedSearchType = 'Artiste';
                    });
                  },
                  child: Row(
                    children: [
                      Radio(
                        value: 'Artiste',
                        groupValue: _selectedSearchType,
                        onChanged: (String? newValue) {
                          // Aucune action nécessaire ici, car l'action est gérée par l'InkWell
                        },
                        activeColor: Colors.white, // Couleur du cercle du bouton radio quand il est sélectionné
                      ),
                      Text('Artiste', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _selectedSearchType == 'Titre'
              ? Expanded(
                child: ListView.separated(
                  itemCount: _tracks.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < _tracks.length) {
                      Track track = _tracks[index];
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
                        onTap: () {
                          context.read<TrackCubit>().addTrack(track);
                          _searchController.clear();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Titre ajouté'),
                                content: Text(
                                    'Le titre a été ajouté à votre liste'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
                ),
              )
              : Expanded(
            child: ListView.separated(
              itemCount: _artists.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < _artists.length) {
                  Artist artist = _artists[index];
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
                    onTap: () {
                      context.read<ArtistCubit>().addArtist(artist);
                      _searchController.clear();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Artiste ajouté'),
                            content: Text(
                                'L\'artiste a été ajouté à votre liste'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
            ),
          ),

        ],
      );
  }

  // Méthode pour mettre à jour les adresses en fonction de la requête de recherche
  void updateTracks(String query) async {
    try {
      List<Track> newTracks = await _trackRepository.fetchTracks(query);
      setState(() {
        _tracks = newTracks;
      });
    } catch (e) {
      print('Erreur lors de la mise à jour des adresses : $e');
      /*if(context.mounted){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Erreur lors de la recherche d\'adresses.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }*/
    }
  }

  // Méthode pour mettre à jour les adresses en fonction de la requête de recherche
  void updateArtists(String query) async {
    try {
      List<Artist> newArtists = await _artistRepository.fetchArtists(query);
      setState(() {
        _artists = newArtists;
      });
    } catch (e) {
      print('Erreur lors de la mise à jour des adresses : $e');
      /*if(context.mounted){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Erreur lors de la recherche d\'adresses.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }*/
    }
  }
}
