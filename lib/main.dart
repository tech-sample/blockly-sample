import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MobileBlocklyPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MobileBlocklyPage extends StatefulWidget {
  @override
  State<MobileBlocklyPage> createState() => _MobileBlocklyPageState();
}

class _MobileBlocklyPageState extends State<MobileBlocklyPage> {
  late final WebViewController _controller;
  String? jsonCode;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          final code = json.decode(message.message);
          setState(() {
            jsonCode = code['json'];
            print('🌐 JavaScript 코드: ${code['javascript']}');
            print('📦 JSON 코드: ${code['json']}');
          });

          sendToServer(code['json'], code['java']); // 서버 전송은 필요 시만
        },
      )
      ..loadFlutterAsset('assets/blockly_editor.html');
  }

  void _getBlocklyCode() {
    _controller.runJavaScript("window.postMessage('get_all');");
  }

  Future<void> sendToServer(String json, String java) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/block');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'json': json, 'java': java}),
    );
    print('서버 응답: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blockly to Java & JSON')),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          ElevatedButton(
            onPressed: _getBlocklyCode,
            child: Text("코드 가져오기 및 전송"),
          ),
        ],
      ),
    );
  }
}
