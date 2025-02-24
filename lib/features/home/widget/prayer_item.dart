import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:my_prayer/resources/app_color.dart';
import 'package:my_prayer/services/scheduler.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:provider/provider.dart';

class PrayerItem extends StatefulWidget {
  final int id;
  final String name;
  final String time;
  final bool isNextPrayer;
  final bool isSound;
  final bool isFirst;
  final bool isLast;

  const PrayerItem({
    super.key,
    required this.id,
    required this.name,
    required this.time,
    required this.isSound,
    required this.isFirst,
    required this.isLast,
    this.isNextPrayer = false,
  });

  @override
  _PrayerItemState createState() => _PrayerItemState();
}

class _PrayerItemState extends State<PrayerItem> {
  late bool isSound;

  _PrayerItemState() : isSound = false;

  @override
  void initState() {
    super.initState();
    isSound =
        widget.isSound; // Set initial sound state based on the next prayer
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        return InkWell(
          borderRadius: _getBorderRadius(widget.isFirst, widget.isLast),
          onTap: () {
            showCustomDialog(
              context,
              (newSound) async {
                if (newSound) {
                  bool result = await PermissionUtils.requestNotification();
                  if (result) {
                    Scheduler.setWorkMangerThreeHour();
                    homeViewModel.updateNotificationPrayer(
                        widget.id, widget.name, newSound, widget.time);
                  } else {
                    return;
                  }
                } else {
                  homeViewModel.updateNotificationPrayer(
                      widget.id, widget.name, newSound, widget.time);
                }
                setState(() {
                  isSound = newSound;
                });
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: getPrayerColor(context, widget.isNextPrayer),
              borderRadius: _getBorderRadius(widget.isFirst, widget.isLast),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: _content(),
                ),
                Divider(
                  height: 0.5,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  BorderRadius _getBorderRadius(bool isFirst, bool isLast) {
    if (isFirst) {
      return BorderRadius.only(
        topLeft: Radius.circular(12.0),
        topRight: Radius.circular(12.0),
      );
    }
    if (isLast) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(12.0),
        bottomRight: Radius.circular(12.0),
      );
    }
    return BorderRadius.all(Radius.zero);
  }

  Widget _content() {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          widget.name,
          style: const TextStyle(fontSize: 24.0),
        ),
        const Spacer(),
        Text(
          widget.time,
          style: const TextStyle(fontSize: 24.0),
        ),
        const SizedBox(width: 8),
        FaIcon(
          isSound ? FontAwesomeIcons.volumeHigh : FontAwesomeIcons.volumeXmark,
          size: 24.0,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void showCustomDialog(BuildContext context, Function(bool) confirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification'),
          actions: [
            TextButton(
              onPressed: () {
                confirm(false); // Silent mode
                Navigator.of(context).pop();
              },
              child: const Text('Silent'),
            ),
            TextButton(
              onPressed: () {
                confirm(true); // Azhan mode
                Navigator.of(context).pop();
              },
              child: const Text('Azhan'),
            ),
          ],
        );
      },
    );
  }
}

Color getPrayerColor(BuildContext context, bool isNextPrayer) {
  if (isNextPrayer) {
    return Theme.of(context).cardColor;
  } else {
    return Theme.of(context).primaryColor;
  }
}
