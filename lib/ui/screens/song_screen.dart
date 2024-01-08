import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_manager/audio_manager.dart';



class SongScreen extends StatelessWidget {
  final List<String> songUrls;
  final List<String> imageUrls;

  SongScreen({required this.songUrls, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SongPlayer(songUrls: songUrls, imageUrls: imageUrls),
    );
  }
}

class SongPlayer extends StatefulWidget {
  final List<String> songUrls;
  final List<String> imageUrls;
  SongPlayer({required this.songUrls, required this.imageUrls});

  @override
  _SongPlayerState createState() => _SongPlayerState();
}


class _SongPlayerState extends State<SongPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<double> _dragPositionController =
      StreamController<double>();
  late List<String> _songUrls;
  late List<String> _imageUrls; 
  late List<String> songTitles; 
  late List<String> albumTitles; 

  @override
  void initState() {
    super.initState();
    _songUrls = widget.songUrls;
    _imageUrls = widget.imageUrls;

    _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        useLazyPreparation: true,
        shuffleOrder: DefaultShuffleOrder(),
        children: [
          for (int i = 0; i < _songUrls.length; i++)
            AudioSource.uri(
              Uri.parse(_songUrls[i]),
            ),
        ],
      ),
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
    _audioPlayer.load();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dragPositionController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentImageUrl = _audioPlayer.currentIndex != null
        ? _imageUrls[_audioPlayer.currentIndex!]
        : 'https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228';

    return Stack(
      fit: StackFit.expand,
      
      children: [

        Image.network(
          currentImageUrl,
          fit: BoxFit.cover,
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
                    ? songTitles[_audioPlayer.currentIndex!]
                    : 'Fallback Title',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Text( //album name
                _audioPlayer.currentIndex != null
                    ? albumTitles[_audioPlayer.currentIndex!]
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
                        onPressed: _audioPlayer.hasNext
                            ? _audioPlayer.seekToNext
                            : null,
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
