import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;

  const AudioPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  _initAudioPlayer() async {
    await _audioPlayer.setUrl(widget.url);

    _audioPlayer.processingStateStream.listen((state) {
      if (mounted) {
        setState(() {
          if (state == ProcessingState.completed) {
            _audioPlayer.pause();
            _audioPlayer.seek(Duration.zero, index: 0);
            isPlaying = false;
          } else {
            isPlaying = _audioPlayer.playing;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
      child: Row(
        children: [
          Center(
            child: StreamBuilder<bool>(
              stream: _audioPlayer.playingStream,
              builder: (context, snapshot) {
                bool? isCurrentlyPlaying = snapshot.data;
                if (isCurrentlyPlaying != null) {
                  isPlaying = isCurrentlyPlaying;
                }
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Color(0xFFB50503),
                      ),
                      iconSize: 20,
                      onPressed: () {
                        if (isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play();
                        }
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            ),
          ),
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _audioPlayer.durationStream
                    .where((duration) => duration != null)
                    .cast<Duration>(),
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, right: 8, left: 8),
                      child: ProgressBar(
                        baseBarColor: Color(0xff9B9B9B),
                        progressBarColor: Color(0xFFB50503),
                        thumbColor: Color(0xFFB50503),
                        progress: position,
                        total: duration,
                        onSeek: (duration) {
                          _audioPlayer.seek(duration);
                        },
                        thumbRadius: 3,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
