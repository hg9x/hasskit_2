import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/model/Setting.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewLoginPage extends StatelessWidget {
  WebViewLoginPage(this.url);
  final String url;
  final String clientId = ('http://hasskit.com');
  final String redirectUri = ('http://hasskit.com');
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    String initialUrl = url +
        '/auth/authorize?client_id=' +
        clientId +
        '&redirect_uri=' +
        redirectUri;
    initialUrl = initialUrl.replaceAll('//auth', "/auth");
//    initUrl = Uri.encodeComponent(initUrl);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: pSetting.appBarThemeChanger,
      ),
      body: Column(
        children: <Widget>[
          pSetting.loading
              ? Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        "Connecting to",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "$url",
                        style: Theme.of(context).textTheme.title,
                        textAlign: TextAlign.center,
                        maxLines: 10,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Make sure the following info are correct",
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "http / https / port number",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Container(),
          Expanded(
            child: WebView(
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                log.d('onWebViewCreated ${_controller.isCompleted}');
              },
              onPageFinished: (finishedString) {
                pSetting.loading = false;
                log.d('onPageFinished finishedString $finishedString');
                if (finishedString.contains('code=')) {
                  var authCode = finishedString.split('code=')[1];
                  pSetting.httpPost(url, authCode, clientId, context);
                  log.d('authCode [' + authCode + ']');
                  pSetting.removeSnackBar(context);
                  log.d('Navigator.pop(context)');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
