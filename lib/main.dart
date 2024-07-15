import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/result.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(MaterialApp(home: QRViewExample()));

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  int parityNum = -1;
  List<String> splitStrList = List.filled(3, '');
  List<String> splitLogList = List.filled(3, '');
  List<String> noSplitStrList = List.filled(3, '');

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('QR Code Data: ${result!.code}'),
                        Text('Format: ${result!.format}'),
                        _byteText(result!),
                      ],
                    )
                  : const Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  Text _byteText(Barcode barcode) {
    List<int>? rawByteList = barcode.rawBytes;

    if (rawByteList == null) {
      return const Text('');
    }

    int byte0 = rawByteList[0];
    int byte1 = rawByteList[1];
    int byte2 = rawByteList[2];
    final int upperBits0 = (byte0! >> 4) & 0x0F; // 上位4ビットを取得
    final int lowerBits0 = byte0 & 0x0F; // 下位4ビットを取得
    final int upperBits1 = (byte1! >> 4) & 0x0F; // 上位4ビットを取得
    final int lowerBits1 = byte1 & 0x0F; // 下位4ビットを取得
    final int upperBits2 = (byte2! >> 4) & 0x0F; // 上位4ビットを取得

    print(rawByteList);
    print(lowerBits1);
    print(upperBits2);

    final String log =
        '分割QRコード: $upperBits0, 分割位置: $lowerBits0, 分割数: $upperBits1';

    if (upperBits0 == 3) {
      _procSplit(
          lowerBits0, upperBits1, lowerBits1 + upperBits2, barcode.code, log);
    } else {
      _procNoSplit(barcode.code);
    }

    if (_isPush()) {
      Future.delayed(Duration.zero, () async {
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => Result(
                splitStrList: splitStrList, splitLogList: splitLogList)));
        splitStrList = List.filled(3, '');
        splitLogList = List.filled(3, '');
      });
    }

    print(splitStrList);
    return Text(log);
  }

  /// 画面遷移するかを判定する
  bool _isPush() {
    for (String str in splitStrList) {
      if (str.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// 普通自動車の場合のロジック<br>
  /// <br>
  /// [splitPos] 分割位置
  void _procSplit(
      int splitPos, int splitCnt, int parity, String? code, String log) {
    if (splitCnt != 2) {
      return;
    }
    if (parityNum == -1) {
      parityNum = parity;
    }

    if (parityNum != parity) {
      return;
    }
    if (splitStrList[splitPos].isNotEmpty) {
      return;
    }

    splitStrList[splitPos] = code ?? '';
    splitLogList[splitPos] = log;
  }

  /// 軽自動車の場合のロジック<br>
  /// <br>
  void _procNoSplit(String? code) {}

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
