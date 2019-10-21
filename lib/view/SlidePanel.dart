import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/WebSocket.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SlidePanel extends StatelessWidget {
  final LoginData loginData;
  const SlidePanel(this.loginData);
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          gd.loginDataCurrent = loginData;
          webSocket.initCommunication();
          gd.showSnackBar('Connect to ${loginData.url}', context);
        },
        child: Card(
          margin: EdgeInsets.all(4),
          color: Colors.white.withOpacity(0.8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                gd.loginDataCurrent.url == loginData.url
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
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Disconnect',
            color: Theme.of(context).primaryColorDark,
            icon: MdiIcons.serverNetworkOff,
            onTap: () {
              gd.showSnackBar('Disconnect from ${loginData.url}', context);
              webSocket.reset();
            }),
        IconSlideAction(
            caption: 'Delete',
            color: Theme.of(context).primaryColorDark,
            icon: Icons.delete,
            onTap: () {
              gd.showSnackBar('Delete', context);
              gd.loginDataListDelete(loginData);
            }),
      ],
    );
  }
}
