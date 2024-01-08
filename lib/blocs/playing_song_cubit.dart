import 'package:flutter_bloc/flutter_bloc.dart';

class PlayingSongState {
  final int indexSong;

  PlayingSongState(this.indexSong);
}

class PlayingSongCubit extends Cubit<PlayingSongState> {
  PlayingSongCubit() : super(PlayingSongState(0));

  void updateIndexSong(int newIndexSong) {
    emit(PlayingSongState(newIndexSong));
  }
}
