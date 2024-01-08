import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../blocs/playing_song_cubit.dart';

class SongScreen extends StatelessWidget {
  final List<String> songUrls;
  final List<String> imageUrls;
  final int indexSong;

  SongScreen({required this.songUrls, required this.imageUrls, required this.indexSong});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SongPlayer(songUrls: songUrls, imageUrls: imageUrls, indexSong: indexSong),
    );
  }
}

class SongPlayer extends StatefulWidget {
  final List<String> songUrls;
  final List<String> imageUrls;
  final int indexSong;
  SongPlayer({required this.songUrls, required this.imageUrls, required this.indexSong});

  @override
  _SongPlayerState createState() => _SongPlayerState();
}


class _SongPlayerState extends State<SongPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<double> _dragPositionController =
      StreamController<double>();
  late List<String> _songUrls;
  late List<String> _imageUrls; 
  late List<String> _songTitles; 
  late List<String> _albumTitles; 
  late int _indexSong;

  @override
  void initState() {
    super.initState();
    _songUrls = widget.songUrls;
    _imageUrls = widget.imageUrls;
    // _songTitles = widget.imageUrls;
    // _albumTitles = widget.albumTitles;
    _indexSong = widget.indexSong;
    print("_indexSong : $_indexSong");
    
    List<AudioSource> audioSources = [];
    for (int i = 0; i < _songUrls.length; i++) {
      if (_songUrls[i] == "not found") {
        audioSources.add(AudioSource.uri(Uri.parse('fallback_uri'), tag: 'Fallback Song'));
      } else {
        audioSources.add(AudioSource.uri(Uri.parse(_songUrls[i]), tag: 'Song $i'));
      }
    }
    _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: audioSources,
      ),
      initialIndex: _indexSong,
      initialPosition: Duration.zero,
    );

    _audioPlayer.load();
    BlocProvider.of<PlayingSongCubit>(context).updateIndexSong(_indexSong);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dragPositionController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    String currentImageUrl = _imageUrls[_indexSong] ?? 'https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228'; //fall back image
    
    return Stack(
      fit: StackFit.expand,
     
      children: [
         Container(
          //margin: EdgeInsets.all(8.0),
          child: Image(
            image: NetworkImage(currentImageUrl),
            fit: BoxFit.cover,
          ),
        ),        

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.withOpacity(0.5),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text( //title
                _audioPlayer.currentIndex != null
                    ? _songTitles[_audioPlayer.currentIndex!]
                    : 'Fallback Title',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Text( //album name
                _audioPlayer.currentIndex != null
                    ? _albumTitles[_audioPlayer.currentIndex!]
                    : 'Fallback Album',
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.white),
              ),

              const SizedBox(height: 30),
              StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final Duration position = snapshot.data ?? Duration.zero;
                  final Duration duration =
                      _audioPlayer.duration ?? Duration.zero;
                  return Column(
                    children: [
                      Text(
                        '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} - ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) {
                          _dragPositionController.add(value);
                        },
                        onChangeEnd: (value) {
                          _audioPlayer
                              .seek(Duration(seconds: value.toInt()));
                        },
                        min: 0.0,
                        max: duration.inSeconds.toDouble(),
                      ),
                    ],
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<SequenceState?>(
                    stream: _audioPlayer.sequenceStateStream,
                    builder: (context, index) {
                      return IconButton(
                        onPressed: _audioPlayer.hasPrevious
                            ? _audioPlayer.seekToPrevious
                            : null,
                        iconSize: 45,
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final playerState = snapshot.data;
                        final processingState = playerState!.processingState;

                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            width: 64.0,
                            height: 64.0,
                            margin: const EdgeInsets.all(10.0),
                            child: const CircularProgressIndicator(),
                          );
                        } else if (!_audioPlayer.playing) {
                          return IconButton(
                            onPressed: _audioPlayer.play,
                            iconSize: 75,
                            icon: const Icon(
                              Icons.play_circle,
                              color: Colors.white,
                            ),
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return IconButton(
                            icon: const Icon(
                              Icons.pause_circle,
                              color: Colors.white,
                            ),
                            iconSize: 75.0,
                            onPressed: _audioPlayer.pause,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(
                              Icons.replay_circle_filled_outlined,
                              color: Colors.white,
                            ),
                            iconSize: 75.0,
                            onPressed: () => _audioPlayer.seek(
                              Duration.zero,
                              index: _audioPlayer.effectiveIndices!.first,
                            ),
                          );
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  StreamBuilder<SequenceState?>(
                    stream: _audioPlayer.sequenceStateStream,
                    builder: (context, index) {
                      return IconButton(
                        onPressed: () {
                          if (_audioPlayer.hasNext) {
                            _audioPlayer.seekToNext();
                            _indexSong += 1;
                            print("_indexSong : $_indexSong");
                          }
                        },
                        iconSize: 45,
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
