import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MP3PickerPage extends StatefulWidget {
  const MP3PickerPage({super.key});

  @override
  _MP3PickerPageState createState() => _MP3PickerPageState();
}

class _MP3PickerPageState extends State<MP3PickerPage> {
  List<String> fileNames = [];
  List<String> filePaths = [];
  AudioPlayer audioPlayer =
      AudioPlayer()
        ..setReleaseMode(ReleaseMode.stop)
        ..setPlayerMode(PlayerMode.mediaPlayer);
  int? currentlyPlayingIndex;
  PlayerState playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    loadFilePaths(); // ✅ 앱 실행 시 저장된 파일 목록 불러오기
  }

  Future<void> pickFiles() async {
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(label: 'MP3', extensions: ['mp3']),
      ],
    );

    if (files.isNotEmpty) {
      final names = files.map((file) => file.name).toList();
      final paths = files.map((file) => file.path).toList();

      setState(() {
        fileNames.addAll(names); // ✅ 기존 리스트에 새 파일명 추가
        filePaths.addAll(paths); // ✅ 기존 리스트에 새 경로 추가
      });

      await saveFilePaths(); // ✅ 새로 선택한 파일 경로 저장
    }
  }

  Future<void> playMusic(int index) async {
    try {
      if (currentlyPlayingIndex == index && playerState == PlayerState.paused) {
        await audioPlayer.resume();
        setState(() {
          playerState = PlayerState.playing;
        });
        showStatusMessage('재생 이어서 시작');
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(DeviceFileSource(filePaths[index]));
        setState(() {
          currentlyPlayingIndex = index;
          playerState = PlayerState.playing;
        });
        showStatusMessage('새 파일 재생 시작: ${fileNames[index]}');
      }
    } catch (e) {
      showStatusMessage('재생 에러: ${fileNames[index]}');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await audioPlayer.pause();
      setState(() {
        playerState = PlayerState.paused;
      });
      showStatusMessage('일시정지 완료');
    } catch (e) {
      showStatusMessage('일시정지 실패');
    }
  }

  Future<void> stopMusic() async {
    try {
      await audioPlayer.stop();
      setState(() {
        playerState = PlayerState.stopped;
        currentlyPlayingIndex = null;
      });
      showStatusMessage('정지 완료');
    } catch (e) {
      showStatusMessage('정지 실패');
    }
  }

  // ✅ 파일 경로 리스트 저장
  Future<void> saveFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mp3_file_paths', filePaths);
  }

  // ✅ 파일 경로 리스트 불러오기
  Future<void> loadFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPaths = prefs.getStringList('mp3_file_paths') ?? [];

    List<String> availableNames = [];
    List<String> availablePaths = [];

    for (String path in savedPaths) {
      final file = File(path);
      if (await file.exists()) {
        availablePaths.add(path);
        availableNames.add(path.split('/').last);
      }
    }

    setState(() {
      filePaths = availablePaths;
      fileNames = availableNames;
    });
  }

  void showStatusMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MP3 파일 선택')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickFiles,
            child: const Text('MP3 파일 선택하기'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fileNames.length,
              itemBuilder: (context, index) {
                final isPlaying =
                    currentlyPlayingIndex == index &&
                    playerState == PlayerState.playing;

                return ListTile(
                  title: Text(fileNames[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          if (isPlaying) {
                            pauseMusic();
                          } else {
                            playMusic(index);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () {
                          stopMusic();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Music Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MP3PickerPage(),
    );
  }
}
