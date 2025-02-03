import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:provider/provider.dart';

class PrayerItem extends StatefulWidget {
  final String name;
  final String time;
  final bool isNextPrayer;
  final bool isSound;

  const PrayerItem({
    super.key,
    required this.name,
    required this.time,
    required this.isSound,
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
          onTap: () {
            showCustomDialog(
              context,
              (bool newSound) async {
                if (newSound == true) {
                  bool result = await PermissionUtils.requestNotification();
                  if (result) {
                    homeViewModel.updateNotificationPrayer(
                        widget.name, newSound);
                  }
                } else {
                  homeViewModel.updateNotificationPrayer(widget.name, newSound);
                }
                setState(() {
                  isSound = newSound;
                });
              },
            );
          },
          child: Card(
            margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            color: widget.isNextPrayer ? Colors.blueAccent : Colors.black38,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _content(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content() {
    return Row(
      children: [
        FaIcon(
          isSound ? FontAwesomeIcons.volumeHigh : FontAwesomeIcons.volumeXmark,
          color: Colors.white54,
          size: 24.0,
        ),
        const SizedBox(width: 8),
        Text(
          widget.name,
          style: const TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        const Spacer(),
        Text(
          widget.time,
          style: const TextStyle(color: Colors.white, fontSize: 24.0),
        ),
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
