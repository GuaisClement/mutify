import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mutify/repositories/track_repository.dart';

import '../models/track.dart';

class TrackCubit extends Cubit<List<Track>> {

  final TrackRepository tracksRepository;

  TrackCubit(this.tracksRepository) : super([]);

  Future<void> loadTracks() async {
    List<Track> tracks = await tracksRepository.loadTracks();
    emit(tracks);
  }

  Future<void> addTrack(Track track) async {
    final updatedTracks = [...state,track];
    emit(updatedTracks);
    await tracksRepository.saveTracks(updatedTracks);
  }

  Future<void> removeTrack(String trackId) async {
    final updatedTracks = state.where((track) => track.id != trackId).toList();
    emit(updatedTracks);
    await tracksRepository.saveTracks(updatedTracks);
  }
}