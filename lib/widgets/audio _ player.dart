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

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  _initAudioPlayer() async {
    await _audioPlayer.setUrl(widget.url);

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                return ProgressBar(
                  progress: position,
                  total: duration,
                  onSeek: (duration) {
                    _audioPlayer.seek(duration);
                  },
                );
              },
            );
          },
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
          },
        ),
      ],
    );
  }
}
