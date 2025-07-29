import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          print('📦 받은 Blockly 코드: ${message.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("받은 코드:\n${message.message}")),
          );
        },
      )
      ..loadFlutterAsset('assets/blockly_editor.html'); // 📌 여기에 HTML 로딩
  }

  void _getBlocklyCode() {
    _controller.runJavaScript("window.postMessage('get_code');");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Blockly Sample')),
        body: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
            ElevatedButton(
              onPressed: _getBlocklyCode,
              child: Text("코드 가져오기"),
            ),
          ],
        ),
      ),
    );
  }
}
