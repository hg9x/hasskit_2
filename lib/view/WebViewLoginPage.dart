import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewLoginPage extends StatefulWidget {
  @override
  _WebViewLoginPageState createState() => _WebViewLoginPageState();
}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    String initialUrl = gd.loginDataCurrent.url +
        '/auth/authorize?client_id=' +
        gd.loginDataCurrent.url +
        "/hasskit" '&redirect_uri=' +
        gd.loginDataCurrent.url +
        "/hasskit";
//    initUrl = Uri.encodeComponent(initUrl);

    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(height: 50),
          gd.webViewLoading
              ? Column(
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
                      "${gd.loginDataCurrent.url}",
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
                        Navigator.pop(context, "Cancel Web Login Connection");
//                        gd.showSnackBar("Cancel Web Login Connection", context);
                      },
                      child: Text("Cancel"),
                    )
                  ],
                )
              : Container(),
          Expanded(
            child: WebView(
              debuggingEnabled: true,
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                log.d('onWebViewCreated ${_controller.isCompleted}');
                setState(() {});
              },
              onPageFinished: (finishedString) {
                gd.webViewLoading = false;
                log.d('onPageFinished finishedString $finishedString');
                if (finishedString.contains('code=')) {
                  var authCode = finishedString.split('code=')[1];
                  gd.sendHttpPost(gd.loginDataCurrent.url, authCode, context);
                  log.d('authCode [' + authCode + ']');
                  gd.removeSnackBar(context);
                  log.d('Navigator.pop(context)');
                }
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
