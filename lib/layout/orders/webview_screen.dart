import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String link;

  const WebViewScreen({super.key, required this.link});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..canGoBack()
      ..currentUrl()
      ..canGoForward()
      ..loadRequest(Uri.parse(widget.link));
    return Scaffold(
        appBar: AppBar(
          title: const Text('دفع أونلاين'),
        ),
        body: Flexible(child: WebViewWidget(controller: controller)));
  }
}
