import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:hasskit_2/model/Setting.dart';
import 'package:validators/validators.dart';
import 'SlidePanel.dart';
import 'SliverAppBarDelegate.dart';
import 'WebViewLoginPage.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final title = 'Setting';
  final addressController = TextEditingController();
  bool showConnect = false;
  bool showCancel = false;
  bool keyboardVisible = false;
  FocusNode addressFocusNode = new FocusNode();

  @override
  void dispose() {
    addressController.removeListener(addressListener);
    addressController.removeListener(addressFocusNodeListener);
    super.dispose();
  }

  @override
  void initState() {
    addressController.addListener(addressListener);
    addressFocusNode.addListener(addressFocusNodeListener);
    super.initState();
  }

  addressFocusNodeListener() {
    if (addressFocusNode.hasFocus) {
      keyboardVisible = true;
      log.d(
          "addressFocusNode.hasFocus ${addressFocusNode.hasFocus} $keyboardVisible");
    } else {
      keyboardVisible = false;
      log.d(
          "addressFocusNode.hasFocus ${addressFocusNode.hasFocus} $keyboardVisible");
    }
  }

  addressListener() {
    if (isURL(addressController.text.trim(),
        requireProtocol: true, protocols: ['http', 'https'])) {
//      log.d("validURL = true isURL ${addressController.text}");
      if (!showConnect) {
        showConnect = true;
        setState(() {});
      }
    } else {
//      log.d("validURL = false isURL ${addressController.text}");
      if (showConnect) {
        showConnect = false;
        setState(() {});
      }
    }

    if (addressController.text.trim().length > 0) {
      if (!showCancel) {
        showCancel = true;
        setState(() {});
      }
    } else {
      if (showCancel) {
        showCancel = false;
        setState(() {});
      }
    }
  }

  SliverPersistentHeader makeHeader(
    Color color,
    Image image,
    String headerText,
    BuildContext context,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SliverAppBarDelegate(
        minHeight: 50,
        maxHeight: 100.0,
        child: Container(
          color: color,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 5),
                    ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 40,
                        child: image,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(headerText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    log.d(
//        "MediaQuery.of(context).viewInsets.vertical ${MediaQuery.of(context).viewInsets.vertical}");

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: pSetting.appBarThemeChanger,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColorLight,
                Theme.of(context).primaryColorDark
              ]),
          color: Theme.of(context).primaryColorLight,
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            makeHeader(
                Theme.of(context).primaryColorDark,
                Image.asset('assets/images/home-assistant-512x512.png'),
                'Connection Setting',
                context),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: addressFocusNode,
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: 'http://sample.duckdns.org:8123',
                        labelText: 'Create New Connection...',
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            showCancel
                                ? IconButton(
                                    icon: Icon(
                                      Icons.cancel,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                    onPressed: () {
                                      addressController.clear();
                                      if (keyboardVisible) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                    },
                                  )
                                : Container(),
                            RaisedButton(
                              onPressed: showConnect
                                  ? () {
                                      if (keyboardVisible) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                      pSetting.loading = true;
                                      showModalBottomSheet(
                                          useRootNavigator: false,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (context) =>
                                              WebViewLoginPage(addressController
                                                  .text
                                                  .trim()));
                                    }
                                  : null,
                              child: Text("Connect"),
                            ),
                          ],
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      onEditingComplete: () {},
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SlidePanel(pLoginData.loginDataList[index]),
                childCount: pLoginData.loginDataList.length,
              ),
            ),
            makeHeader(Theme.of(context).primaryColorDark,
                Image.asset('assets/images/icon.png'), 'Quick Tour', context),
            SliverFixedExtentList(
              itemExtent: 150.0,
              delegate: SliverChildListDelegate(
                [
                  Container(),
                  Container(),
                  Container(),
                  Container(),
                  Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
