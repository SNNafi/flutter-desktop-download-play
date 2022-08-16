import 'dart:ffi';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_desktop_download_play/utils/Utils.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';

List<ItemModel> surahList = positiveIntegers
    .skip(1)
    .take(114)
    .map((i) => ItemModel(i, i.toString(),
        "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${numberFormatter.format(i)}.mp3"))
    .toList();

// List<ItemModel> items = [
//   ItemModel(1, "Surah Al Fatiha",
//       "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/001.mp3"),
//   ItemModel(2, "Surah Al Baqarah",
//       "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/002.mp3"),
//   ItemModel(3, "Surah Al Imran",
//       "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/003.mp3")
// ];

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with AutomaticKeepAliveClientMixin {
  var downloadManager = DownloadManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: surahList.length,
        itemBuilder: (context, index) {
          final surah = surahList[index];
          return Item(
            itemModel: surah,
            downloadTask: downloadManager.getDownload(surah.url),
            onTap: () {
              print(surah.url);
              getApplicationSupportDirectory().then((dir) {
                print(dir.path);
                final downloadPath = dir.path + "/audios/" + surah.fileName;

                setState(() {
                  downloadManager.addDownload(surah.url, downloadPath);
                });
              });
            },
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class Item extends StatefulWidget {
  final ItemModel itemModel;
  DownloadTask? downloadTask;
  final VoidCallback onTap;

  Item(
      {Key? key,
      required this.itemModel,
      required this.onTap,
      this.downloadTask})
      : super(key: key);

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(widget.itemModel.title),
                  widget.downloadTask != null
                      ? ValueListenableBuilder<DownloadStatus>(
                          valueListenable: widget.downloadTask!.status,
                          builder: (context, value, child) {
                            if (value == DownloadStatus.downloading) {
                              return SizedBox();
                            } else {
                              return TextButton(
                                  onPressed: () {
                                    widget.onTap();
                                  },
                                  child: Icon(Icons.download));
                            }
                          })
                      : TextButton(
                          onPressed: () {
                            widget.onTap();
                          },
                          child: Icon(Icons.download))
                ],
              ),
            ),
            if (widget.downloadTask != null)
              ValueListenableBuilder<DownloadStatus>(
                  valueListenable: widget.downloadTask!.status,
                  builder: (context, value, child) {
                    if (value == DownloadStatus.downloading) {
                      return ValueListenableBuilder<double>(
                          valueListenable: widget.downloadTask!.progress,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.amber),
                                value: value,
                              ),
                            );
                          });
                    } else {
                      return SizedBox();
                    }
                  }),
          ],
        ),
      ),
    );
  }
}

class ItemModel {
  int id;
  String title;
  String url;

  String get fileName => title.replaceAll(" ", "").trim() + ".mp3";

  ItemModel(this.id, this.title, this.url);
}
