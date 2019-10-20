import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hasskit_2/helper/providerData.dart';
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
      child: Card(
//        color: Theme.of(context).primaryColorLight,
        child: ListTile(
          onTap: () {
            pD.loginDataListUpdateAccessTime(loginData);
          },
          leading: Icon(
            MdiIcons.serverNetwork,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(loginData.url,
              style: Theme.of(context).textTheme.subhead,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          subtitle: Text("Last Access: ${loginData.timeSinceLastAccess}",
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
              pD.showSnackBar('Delete', context);
              pD.loginDataListDelete(loginData);
            }),
      ],
    );
  }
}
