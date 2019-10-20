import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/helper/providerData.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewLoginPage extends StatelessWidget {
  WebViewLoginPage();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    String initialUrl = pD.url +
        '/auth/authorize?client_id=' +
        pD.url +
        "/hasskit" '&redirect_uri=' +
        pD.url +
        "/hasskit";
//    initUrl = Uri.encodeComponent(initUrl);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: pD.appBarThemeChanger,
      ),
      body: Column(
        children: <Widget>[
          pD.loading
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
                        "${pD.url}",
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
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      )
                    ],
                  ),
                )
              : Container(),
          Expanded(
            child: WebView(
              debuggingEnabled: true,
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                Logger.d('onWebViewCreated ${_controller.isCompleted}');
              },
              onPageFinished: (finishedString) {
                pD.loading = false;
                Logger.d('onPageFinished finishedString $finishedString');
                if (finishedString.contains('code=')) {
                  var authCode = finishedString.split('code=')[1];
                  pD.sendHttpPost(pD.url, authCode, context);
                  Logger.d('authCode [' + authCode + ']');
                  pD.removeSnackBar(context);
                  Logger.d('Navigator.pop(context)');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
