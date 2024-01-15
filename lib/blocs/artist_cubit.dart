import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/repositories/track_repository.dart';

import '../models/artist.dart';
import '../models/track.dart';
import '../repositories/artist_repository.dart';

class ArtistCubit extends Cubit<List<Artist>> {

  final ArtistRepository artistsRepository;

  ArtistCubit(this.artistsRepository) : super([]);

  Future<void> loadArtists() async {
    List<Artist> artists = await artistsRepository.loadArtists();
    emit(artists);
  }

  Future<void> addArtist(Artist artist) async {
    final updatedArtists = [...state,artist];
    emit(updatedArtists);
    await artistsRepository.saveArtists(updatedArtists);
  }

  Future<void> removeArtist(String artistId) async {
    final updatedArtists = state.where((track) => track.id != artistId).toList();
    emit(updatedArtists);
    await artistsRepository.saveArtists(updatedArtists);
  }
}