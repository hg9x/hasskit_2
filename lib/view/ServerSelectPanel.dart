import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ServerSelectPanel extends StatelessWidget {
  final LoginData loginData;
  const ServerSelectPanel(this.loginData);
  @override
  Widget build(BuildContext context) {
    List<Widget> secondaryWidgets;
    Widget deleteWidget = new IconSlideAction(
        caption: 'Delete',
        color: Colors.transparent,
        icon: Icons.delete,
        onTap: () {
          gd.showSnackBar('Delete', context);
          gd.loginDataListDelete(loginData);
          if (gd.loginDataCurrent.url == loginData.url) {
            webSocket.reset();
          }
        });
    secondaryWidgets = [deleteWidget];
    if (gd.loginDataCurrent.url == loginData.url) {
      var disconnectWidget = IconSlideAction(
          caption: 'Disconnect',
          color: Colors.transparent,
          icon: MdiIcons.serverNetworkOff,
          onTap: () {
            gd.showSnackBar('Disconnect from ${loginData.url}', context);
            webSocket.reset();
          });
      secondaryWidgets = [disconnectWidget, deleteWidget];
    } else {
      secondaryWidgets = [deleteWidget];
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          if (gd.loginDataCurrent.url == loginData.url &&
              gd.connectionStatus == "Connected") {
            gd.showSnackBar(
                "Swift Right to Refresh, Left to Disconnect/Delete", context);
          } else {
            gd.showSnackBar("Swift Right to Connect, Left to Delete", context);
          }
        },
        child: Card(
          margin: EdgeInsets.all(4),
          color: Colors.white.withOpacity(0.8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                gd.loginDataCurrent.url == loginData.url &&
                        gd.connectionStatus == "Connected"
                    ? Icon(
                        MdiIcons.serverNetwork,
                        color: Theme.of(context).primaryColorDark,
                      )
                    : Icon(
                        MdiIcons.serverNetworkOff,
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.5),
                      ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(loginData.url,
                          style: Theme.of(context).textTheme.subhead,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          gd.loginDataCurrent.url == loginData.url
                              ? "Status: ${gd.connectionStatus}"
                              : "Last Access: ${loginData.timeSinceLastAccess}",
                          style: Theme.of(context).textTheme.body1,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        (gd.loginDataCurrent.url == loginData.url &&
                gd.connectionStatus == "Connected")
            ? IconSlideAction(
                caption: 'Refresh',
                color: Colors.transparent,
                icon: MdiIcons.refresh,
                onTap: () {
                  gd.showSnackBar(
                      'Refresh data from ${loginData.url}', context);
                  webSocket.initCommunication();
                })
            : IconSlideAction(
                caption: 'Connect',
                color: Colors.transparent,
                icon: MdiIcons.serverNetwork,
                onTap: () {
                  gd.showSnackBar('Connect to ${loginData.url}', context);
                  gd.loginDataCurrent = loginData;
                  webSocket.initCommunication();
                }),
      ],
      secondaryActions: secondaryWidgets,
    );
  }
}
