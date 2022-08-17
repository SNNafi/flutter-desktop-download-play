import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_desktop_download_play/download/DownloadPage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({Key? key}) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with AutomaticKeepAliveClientMixin {
  final player = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    print("initPlayer");
    getApplicationSupportDirectory().then((dir) {
      print(dir.path);

      var directory = Directory(dir.path + "/audios/");

      if (Platform.isWindows) {
        final filePath = dir.path + "/audios/" + surahList[0].fileName;
        print(filePath);
        player.setFilePath(filePath);
      } else {
        List<UriAudioSource> audioSources = directory
            .listSync()
            .where((element) => element.path.toString().contains(".mp3"))
            .map((element) => AudioSource.uri(Uri.file(element.path),
                tag: basename(element.path).replaceAll(".mp3", "")))
            .toList();
        audioSources.sort((a, b) => int.parse(a.tag.replaceAll(".mp3", ""))
            .compareTo(int.parse(b.tag.replaceAll(".mp3", ""))));

        player.setAudioSource(ConcatenatingAudioSource(children: audioSources));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initPlayer();
        },
        child: Icon(Icons.sync),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<SequenceState?>(
                  stream: player.sequenceStateStream,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        snapshot.data?.currentSource?.tag ?? "",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder<Duration?>(
                  stream: player.durationStream,
                  builder: (context, total) {
                    return StreamBuilder<Duration>(
                      stream: player.bufferedPositionStream,
                      builder: (context, buffered) {
                        return StreamBuilder<Duration>(
                          stream: player.positionStream,
                          builder: (context, position) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _progressBar(context, position.data,
                                  buffered.data, total.data),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreamBuilder<bool>(
                      stream: player.shuffleModeEnabledStream,
                      builder: (context, snapshot) {
                        return _shuffleButton(context, snapshot.data ?? false);
                      },
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    StreamBuilder<LoopMode>(
                      stream: player.loopModeStream,
                      builder: (context, snapshot) {
                        return _repeatButton(
                            context, snapshot.data ?? LoopMode.off);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreamBuilder<SequenceState?>(
                      stream: player.sequenceStateStream,
                      builder: (_, __) {
                        return _previousButton();
                      },
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    StreamBuilder<PlayerState?>(
                      stream: player.playerStateStream,
                      builder: (_, snapshot) {
                        final playerState = snapshot.data;
                        return _playPauseButton(playerState ??
                            PlayerState(false, ProcessingState.idle));
                      },
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    StreamBuilder<SequenceState?>(
                      stream: player.sequenceStateStream,
                      builder: (_, __) {
                        return _nextButton();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(120),
        child: Container(
          color: Colors.amber,
          child: SizedBox(
            width: 64,
            height: 64,
            child: IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Color(0xff242A3D),
                size: 36,
              ),
              onPressed: player.play,
            ),
          ),
        ),
      );
    } else if (processingState != ProcessingState.completed) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(120),
        child: Container(
          color: Colors.amber,
          child: SizedBox(
            width: 64,
            height: 64,
            child: IconButton(
              icon: const Icon(
                Icons.pause,
                color: Color(0xff242A3D),
                size: 36,
              ),
              onPressed: player.pause,
            ),
          ),
        ),
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.replay,
          color: Colors.black,
        ),
        iconSize: 64.0,
        onPressed: () =>
            player.seek(Duration.zero, index: player.effectiveIndices?.first),
      );
    }
  }

  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      iconSize: 35,
      color: Colors.black,
      onPressed: player.hasPrevious ? player.seekToPrevious : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      color: Colors.black,
      iconSize: 35,
      onPressed: player.hasNext ? player.seekToNext : null,
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(
        Icons.repeat,
        color: Colors.black,
      ),
      Icon(Icons.repeat, color: Theme.of(context).accentColor),
      Icon(Icons.repeat_one, color: Theme.of(context).accentColor),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      color: Colors.black,
      onPressed: () {
        player.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(Icons.shuffle, color: Theme.of(context).accentColor)
          : Icon(
              Icons.shuffle,
              color: Colors.black,
            ),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await player.shuffle();
        }
        await player.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _progressBar(BuildContext context, Duration? position,
      Duration? buffered, Duration? total) {
    return ProgressBar(
      progressBarColor: Colors.amber,
      baseBarColor: Color(0xff303954),
      bufferedBarColor: Colors.amber.shade200,
      timeLabelTextStyle: TextStyle(color: Color(0xff9FA1AB)),
      progress: position ?? Duration(seconds: 0),
      buffered: buffered,
      total: total ?? Duration(seconds: 0),
      onSeek: (position) {
        player.seek(position);
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
