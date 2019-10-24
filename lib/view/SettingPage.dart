import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/Logger.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/MaterialDesignIcons.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:validators/validators.dart';
import 'ServerSelectPanel.dart';
import 'WebViewLoginPage.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final title = 'Setting';
  final _controller = TextEditingController();
  bool showConnect = false;
  bool showCancel = false;
  bool keyboardVisible = false;
  FocusNode addressFocusNode = new FocusNode();

  @override
  void dispose() {
    _controller.removeListener(addressListener);
    _controller.removeListener(addressFocusNodeListener);
    super.dispose();
  }

  @override
  void initState() {
    _controller.addListener(addressListener);
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
    if (isURL(_controller.text.trim(), protocols: ['http', 'https'])) {
//      Logger.d("validURL = true isURL ${addressController.text}");
      if (!showConnect) {
        showConnect = true;
        setState(() {});
      }
    } else {
//      Logger.d("validURL = false isURL ${addressController.text}");
      if (showConnect) {
        showConnect = false;
        setState(() {});
      }
    }

    if (_controller.text.trim().length > 0) {
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

  @override
  Widget build(BuildContext context) {
    if (gd.loginDataList.length > 0 &&
        gd.loginDataList[0].url.trim() == _controller.text.trim()) {
      log.w("gd.loginDataList[0].url.trim() ==_controller.text.trim()");
      _controller.clear();
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(gd.backgroundImage[1]),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColorLight,
              Theme.of(context).primaryColorDark.withOpacity(0.2)
            ]),
        color: Theme.of(context).primaryColorLight,
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            leading: Image(
              image: AssetImage(
                  'assets/images/icon_transparent_border_transparent.png'),
            ),
            largeTitle: Text(title),
            trailing: IconButton(
              icon: Icon(Icons.palette),
              onPressed: () {
                gd.themeChange();
              },
            ),
          ),
          gd.makeHeaderIcon(
              Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:home-assistant"),
              ),
              'Home Assistant Connection',
              "",
              context),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        focusNode: addressFocusNode,
                        controller: _controller,
                        decoration: InputDecoration(
                          prefixText: gd.useSSL ? "https://" : "http://",
                          hintText: 'sample.duckdns.org:8123',
                          labelText: 'Create New Connection...',
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              showCancel
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Theme.of(context)
                                            .toggleableActiveColor,
                                      ),
                                      onPressed: () {
                                        _controller.clear();
                                        if (keyboardVisible) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        }
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        onChanged: (val) {},
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                      _controller.text.trim().length > 0
                          ? Row(
                              children: <Widget>[
                                Switch.adaptive(
                                    value: gd.useSSL,
                                    onChanged: (val) {
                                      gd.useSSL = val;
                                    }),
                                Text("Use SSL"),
                                Expanded(child: Container()),
                                RaisedButton(
                                  onPressed: showConnect
                                      ? () {
                                          if (keyboardVisible) {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          }
                                          gd.loginDataCurrent = LoginData(
                                              url: gd.useSSL
                                                  ? "https://" +
                                                      gd.trimUrl(
                                                          _controller.text)
                                                  : "http://" +
                                                      gd.trimUrl(
                                                          _controller.text));
                                          gd.webViewLoading = true;
                                          showModalBottomSheet(
                                              context: context,
                                              elevation: 1,
                                              backgroundColor: Theme.of(context)
                                                  .primaryColorDark
                                                  .withOpacity(0.8),
                                              isScrollControlled: true,
                                              useRootNavigator: true,
                                              builder: (context) =>
                                                  WebViewLoginPage());
                                        }
                                      : null,
                                  child: Text("Connect"),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ServerSelectPanel(gd.loginDataList[index]),
              childCount: gd.loginDataList.length,
            ),
          ),
          gd.makeHeaderIcon(
              Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:view-carousel")),
              'Room Setting',
              "",
              context),
          SliverFixedExtentList(
            itemExtent: 160,
            delegate: SliverChildListDelegate(
              [
                Container(color: Colors.transparent),
//                Container(
//                  child: Container(
//                    child: ListView.builder(
//                      scrollDirection: Axis.horizontal,
//                      itemCount: gd.roomList.length,
//                      itemBuilder: (context, index) {
//                        return Container(
//                          width: 100,
//                          child: RoomCard(roomIndex: index),
//                        );
//                      },
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
          gd.makeHeaderIcon(
              Theme.of(context).primaryColorDark.withOpacity(0.2),
              Icon(MaterialDesignIcons.getIconDataFromIconName(
                  "mdi:account-circle")),
              'About HassKit',
              "",
              context),
          SliverFixedExtentList(
            itemExtent: 1000.0,
            delegate: SliverChildListDelegate(
              [
                Container(color: Colors.transparent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
