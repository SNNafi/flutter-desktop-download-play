import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';

final downloadManager = DownloadManager();

List<ItemModel> items = [
  ItemModel(1, "Surah Al Fatiha",
      "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/001.mp3"),
  ItemModel(2, "Surah Al Baqarah",
      "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/002.mp3"),
  ItemModel(3, "Surah Al Imran",
      "https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/003.mp3")
];

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Item(itemModel: items[index]);
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class Item extends StatelessWidget {
  final ItemModel itemModel;

  const Item({Key? key, required this.itemModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(itemModel.title),
            TextButton(
                onPressed: () {
                  print(itemModel.url);
                  getApplicationSupportDirectory().then((dir) {
                    print(dir.path);
                    final downloadPath =
                        dir.path + "/audios/" + itemModel.fileName;
                    downloadManager.download(
                        itemModel.url, downloadPath, CancelToken());
                  }).then((value) => print("Complete"));
                },
                child: Icon(Icons.download))
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
