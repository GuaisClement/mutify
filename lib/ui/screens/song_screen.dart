import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../blocs/playing_song_cubit.dart';
import '../../blocs/track_cubit.dart';

class SongScreen extends StatelessWidget {
  SongScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SongPlayer(),
    );
  }
}

class SongPlayer extends StatefulWidget {
  SongPlayer();

  @override
  _SongPlayerState createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<double> _dragPositionController =
      StreamController<double>();
  final StreamController<String> _currentImageUrlController =
      StreamController<String>();
  final StreamController<String> _currentTitleController =
      StreamController<String>();
  final StreamController<String> _currentArtistsController =
      StreamController<String>();

  String currentImageUrl ='https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228'; // fallback image
  String currentTitle = '';
  String currentArtists = '';

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final PlayingSongCubit playingSongCubit =
        BlocProvider.of<PlayingSongCubit>(context);
        
    final TrackCubit trackCubit =BlocProvider.of<TrackCubit>(context);

    // Set up the audio player with the cubit's current index
    List<AudioSource> audioSources = [];
    for (int i = 0; i < trackCubit.state.length; i++) {    
      audioSources.add(AudioSource.uri(Uri.parse(trackCubit.state[i].previewUrl),
          tag: 'Song $i'));      
    }

    _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: audioSources,
      ),
      initialIndex: playingSongCubit.state.indexSong,
      initialPosition: Duration.zero,
    );
    _audioPlayer.load();

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < trackCubit.state.length) {
        setState(() {
          currentImageUrl = trackCubit.state[index].imageUrl;
          currentTitle = trackCubit.state[index].name;
          currentArtists = trackCubit.state[index].artists;
          if (_audioPlayer.duration==null){
            //showSnackbar('Song Preview Not Found');                                
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dragPositionController.close();
    _currentImageUrlController.close();
    _currentTitleController.close();
    _currentArtistsController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayingSongCubit playingSongCubit =BlocProvider.of<PlayingSongCubit>(context);
    final TrackCubit trackCubit =BlocProvider.of<TrackCubit>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body : Stack(
        fit: StackFit.expand,     
        children: [
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
            child: Image(
              image: NetworkImage(currentImageUrl),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( //title
                  currentTitle,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),
                Text( //album name
                  currentArtists,
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
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
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
                          onPressed: () {
                            if (playingSongCubit.state.indexSong>0) {
                              _audioPlayer.seekToPrevious();                            
                              playingSongCubit.updateIndexSong(playingSongCubit.state.indexSong - 1);
                              if (_audioPlayer.duration==null){
                                showSnackbar('Song Preview Not Found');                                
                              }
                            }
                          },
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
                            if (playingSongCubit.state.indexSong<trackCubit.state.length-1) {                              
                              _audioPlayer.seekToNext();                            
                              playingSongCubit.updateIndexSong(playingSongCubit.state.indexSong + 1);  
                              if (_audioPlayer.duration==null){
                                showSnackbar('Song Preview Not Found');                                
                              }
                              
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
      )
    );
  }
}
