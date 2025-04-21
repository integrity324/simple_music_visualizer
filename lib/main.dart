import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

void main() {
  runApp(MyApp());
}

// 앱 전체 구조
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'MP3 Picker', home: MP3PickerPage());
  }
}

// MP3 선택 및 리스트 화면
class MP3PickerPage extends StatefulWidget {
  const MP3PickerPage({super.key});

  @override
  _MP3PickerPageState createState() => _MP3PickerPageState();
}

class _MP3PickerPageState extends State<MP3PickerPage> {
  // 선택한 파일 이름 리스트
  List<String> fileNames = [];

  // MP3 파일 선택 함수
  Future<void> pickFiles() async {
    // 여러 개의 MP3 파일 선택
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(label: 'MP3', extensions: ['mp3']),
      ],
    );

    if (files.isNotEmpty) {
      final names = files.map((file) => file.name).toList();

      setState(() {
        fileNames = names;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MP3 파일 선택')),
      body: Column(
        children: [
          // 파일 선택 버튼
          ElevatedButton(onPressed: pickFiles, child: Text('MP3 파일 선택하기')),
          // 선택한 파일 이름 리스트뷰
          Expanded(
            child: ListView.builder(
              itemCount: fileNames.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(fileNames[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
