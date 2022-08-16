import 'package:flutter/material.dart';
import 'package:flutter_desktop_download_play/download/DownloadPage.dart';
import 'package:flutter_desktop_download_play/pdf/DownloadAndReadPDF.dart';
import 'package:flutter_desktop_download_play/play/AudioPlayerPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    DownloadPage(),
    AudioPlayerPage(),
    DownloadAndReadPDF()
  ];

  late PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.download_for_offline_outlined,
              color: Colors.amber,
            ),
            activeIcon: Icon(
              Icons.download_for_offline,
              color: Colors.amber,
            ),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.play_circle_outline,
              color: Colors.amber,
            ),
            activeIcon: Icon(
              Icons.play_circle,
              color: Colors.amber,
            ),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chrome_reader_mode_outlined,
              color: Colors.amber,
            ),
            activeIcon: Icon(
              Icons.chrome_reader_mode,
              color: Colors.amber,
            ),
            label: 'Read',
          ),
        ],
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(_currentIndex);
    });
  }
}
