import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hasskit_2/model/LoginData.dart';
import 'package:hasskit_2/model/Setting.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SlidePanel extends StatelessWidget {
  final LoginData loginData;
  const SlidePanel(this.loginData);
  @override
  Widget build(BuildContext context) {
//    for (LoginData loginData in pSetting.loginDataList) {
//      log.d("url ${loginData.url} "
//          "accessToken ${loginData.accessToken} "
//          "expiresIn ${loginData.expiresIn} "
//          "refreshToken ${loginData.refreshToken} "
//          "tokenType ${loginData.tokenType} ");
//    }

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
//        color: Theme.of(context).primaryColorLight,
        child: ListTile(
          onTap: () {
            pLoginData.loginDataListUpdateAccessTime(loginData);
          },
          leading: Icon(
            MdiIcons.serverNetwork,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(loginData.url,
              style: Theme.of(context).textTheme.subhead,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          subtitle: Text(
//              "accessToken ${loginData.accessToken.length} "
//              "expiresIn ${loginData.expiresIn} "
//              "refreshToken ${loginData.refreshToken.length} "
//              "tokenType ${loginData.tokenType} "
//              "lastAccess ${loginData.lastAccess} "
              "Last Access: ${loginData.timeSinceLastAccess}"
//              " (${DateTime.now().toUtc().millisecondsSinceEpoch - loginData.lastAccess})"
              ,
              style: Theme.of(context).textTheme.body1,
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Theme.of(context).primaryColorDark,
            icon: Icons.delete,
            onTap: () {
              pSetting.showSnackBar('Delete', context);
              pLoginData.loginDataListDelete(loginData.url);
            }),
      ],
    );
  }
}
