import 'package:flutter/material.dart';

class PrayerItem extends StatelessWidget {
  final String name;
  final String time;
  final bool isNextPrayer;

  const PrayerItem(
      {required Key key,
      required this.name,
      required this.time,
      this.isNextPrayer = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: isNextPrayer ? Colors.blueAccent : Colors.black38,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: content(),
            ),
            Divider(color: isNextPrayer ? Colors.white : Colors.white54),
          ],
        ));
  }

  Widget content() {
    return Row(children: [
      Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 24.0),
      ),
      const Spacer(
        flex: 1,
      ),
      Text(
        time,
        style: const TextStyle(color: Colors.white, fontSize: 24.0),
      )
    ]);
  }
}
