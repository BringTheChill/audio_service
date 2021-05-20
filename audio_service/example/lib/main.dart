import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool isBgVolumeOnMute = false;
late AudioHandler audioHandler;

Future<void> main() async {
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerTask(),
    config: AudioServiceConfig(
      androidEnableQueue: false,
      androidStopForegroundOnPause: false,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            await audioHandler.playFromUri(Uri.parse("It doesn't matter"));
          },
          child: Text('Press to play'),
        ),
      ),
    );
  }
}

class AudioPlayerTask extends BaseAudioHandler with QueueHandler, SeekHandler {
  AudioPlayer playerBackground = AudioPlayer(playerId: 'background');

  AudioPlayerTask() {
    queue.add(null);
    playerBackground.onPlayerStateChanged.listen((state) async {
      final playing = state == PlayerState.PLAYING;
      playbackState.add(playbackState.value!.copyWith(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
        ],
        systemActions: {
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        playing: playing,
      ));
    });
  }

  @override
  Future<void> play() async {
    playerBackground.resume();
    return super.play();
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    var currentMediaItem = MediaItem(
      id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 5739820),
      artUri: Uri.parse(
          'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
    );
    await playerBackground.setReleaseMode(ReleaseMode.LOOP);
    await playerBackground.play(
      currentMediaItem.id,
      isLocal: false,
      stayAwake: true,
    );
    mediaItem.add(currentMediaItem);
    return super.playFromUri(uri, extras);
  }

  @override
  Future<void> pause() {
    playerBackground.pause();
    return super.pause();
  }

  @override
  Future<void> stop() async {
    playerBackground.stop();
    return super.stop();
  }
}
