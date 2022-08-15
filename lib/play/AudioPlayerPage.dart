import 'package:flutter/material.dart';
import 'package:flutter_desktop_download_play/download/DownloadPage.dart';
import 'package:just_audio/just_audio.dart';
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
    getApplicationSupportDirectory().then((dir) {
      print(dir.path);
      final filePath = dir.path + "/audios/" + items[0].fileName;
      player.setFilePath(filePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              player.play();
            },
          ),
          TextButton(
            child: Icon(Icons.pause),
            onPressed: () {
              player.pause();
            },
          ),
        ],
      ),
    ));
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
