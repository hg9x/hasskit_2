import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/ThemeInfo.dart';

class QuickGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.only(top: 20, left: 60, right: 60, bottom: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 5, color: Colors.black),
              ),
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/guide-01.png"),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Step 1:\n\nGo to Setting Tap and Enter your Home Assistant server adddress. Please make sure the protocol (http or https) and the port (443 or 8123) are correct.",
                style: Theme.of(context).textTheme.body1,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, left: 60, right: 60, bottom: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 5, color: Colors.black),
              ),
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/guide-02.png"),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Step 2:\n\nLogin with your Home Assistant Account and wait for a few seconds, HassKit will save login token for you. We don't need to login everytime start using this app",
                style: Theme.of(context).textTheme.body1,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, left: 60, right: 60, bottom: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 5, color: Colors.black),
              ),
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/guide-03.png"),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Step 3:\n\nClick Room tab and keep swiping to the right until you see the Default Room",
                style: Theme.of(context).textTheme.body1,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, left: 60, right: 60, bottom: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 5, color: Colors.black),
              ),
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/guide-04.png"),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Step 4:\n\nClick the device detail setting, you can chose to show the device on Home page and on one another page",
                style: Theme.of(context).textTheme.body1,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
