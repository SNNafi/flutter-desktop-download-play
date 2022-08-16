import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

final pdfURL = "https://app.snnafi.com/OUT/quran_mushaf_madina.pdf";
final pdf = "quran_mushaf_madina.pdf";

class DownloadAndReadPDF extends StatefulWidget {
  const DownloadAndReadPDF({Key? key}) : super(key: key);

  @override
  State<DownloadAndReadPDF> createState() => _DownloadAndReadPDFState();
}

class _DownloadAndReadPDFState extends State<DownloadAndReadPDF>
    with AutomaticKeepAliveClientMixin {
  var downloadManager = DownloadManager();
  DownloadTask? downloadTask = null;
  var checking = true;
  var found = false;
  var pdfPath = "";

  void checkPDF() async {
    final dir = await getApplicationSupportDirectory();
    pdfPath = dir.path + "/pdf/" + pdf;
    setState(() {
      final pdfFile = File(pdfPath);
      print(pdfPath);
      if (pdfFile.existsSync()) {
        found = true;
        checking = false;
      } else {
        checking = false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPDF();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: checking
          ? Center(
              child: CircularProgressIndicator(),
            )
          : found
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: Builder(builder: (context) {
                    if (!Platform.isWindows) {
                      final pdfPinchController = PdfControllerPinch(
                        document: PdfDocument.openFile(pdfPath),
                      );
                      return PdfViewPinch(
                        controller: pdfPinchController,
                      );
                    } else {
                      final pdfController = PdfController(
                        document: PdfDocument.openFile(pdfPath),
                      );
                      return PdfView(
                        controller: pdfController,
                      );
                    }
                  }),
                )
              : Center(
                  child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        downloadTask != null
                            ? ValueListenableBuilder<DownloadStatus>(
                                valueListenable: downloadTask!.status,
                                builder: (context, value, child) {
                                  if (value == DownloadStatus.downloading) {
                                    return SizedBox();
                                  } else {
                                    checkPDF();
                                    return TextButton(
                                        onPressed: () {
                                          getApplicationSupportDirectory()
                                              .then((dir) {
                                            print(dir.path);
                                            final downloadPath =
                                                dir.path + "/pdf/" + pdf;
                                            setState(() {
                                              downloadManager.addDownload(
                                                  pdfURL, downloadPath);
                                              downloadTask = downloadManager
                                                  .getDownload(pdfURL);
                                            });
                                          });
                                        },
                                        child: Icon(Icons.download));
                                  }
                                })
                            : TextButton(
                                onPressed: () {
                                  getApplicationSupportDirectory().then((dir) {
                                    print(dir.path);
                                    final downloadPath =
                                        dir.path + "/pdf/" + pdf;
                                    setState(() {
                                      downloadManager.addDownload(
                                          pdfURL, downloadPath);
                                      downloadTask =
                                          downloadManager.getDownload(pdfURL);
                                    });
                                  });
                                },
                                child: Icon(Icons.download)),
                        if (downloadTask != null)
                          ValueListenableBuilder<DownloadStatus>(
                              valueListenable: downloadTask!.status,
                              builder: (context, value, child) {
                                if (value == DownloadStatus.downloading) {
                                  return ValueListenableBuilder<double>(
                                      valueListenable: downloadTask!.progress,
                                      builder: (context, value, child) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.grey,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.amber),
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
                )),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
