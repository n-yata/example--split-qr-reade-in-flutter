import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  const Result(
      {super.key, required this.splitStrList, required this.splitLogList});

  final List<String> splitStrList;
  final List<String> splitLogList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR scan result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(splitStrList[0]),
            Text(splitLogList[0]),
            const Text(''),
            Text(splitStrList[1]),
            Text(splitLogList[1]),
            const Text(''),
            Text(splitStrList[2]),
            Text(splitLogList[2]),
            const Text(''),
            ElevatedButton(
              child: const Text('戻る'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
