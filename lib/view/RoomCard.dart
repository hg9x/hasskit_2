import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/GeneralData.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';
import 'package:hasskit_2/view/RoomEditPage.dart';

class RoomCard extends StatelessWidget {
  final int roomIndex;
  const RoomCard({@required this.roomIndex});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          elevation: 1,
          backgroundColor: ThemeInfo.colorBottomSheet,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return RoomEditPage(roomIndex: roomIndex);
          },
        );
      },
      child: Card(
        margin: EdgeInsets.all(4),
        elevation: 0,
        semanticContainer: false,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                  gd.backgroundImage[gd.roomList[roomIndex].imageIndex]),
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                "${gd.roomList[roomIndex].name}",
                style: Theme.of(context).textTheme.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              roomIndex == gd.roomList.length - 1
                  ? Expanded(
                      child: Icon(
                      Icons.add_box,
                      size: 80,
                      color:
                          Theme.of(context).primaryColorLight.withOpacity(0.8),
                    ))
                  : Container(),
              Container(
                height: roomIndex == gd.roomList.length - 1 ? 30 : 0,
              )
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
