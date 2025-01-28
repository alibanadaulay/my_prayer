import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:provider/provider.dart';

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
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        return InkWell(
          onTap: () {},
          child: Card(
            margin: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            color: isNextPrayer ? Colors.blueAccent : Colors.black38,
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
          FontAwesomeIcons.clock,
          color: Colors.white54,
          size: 24.0,
        ),
        SizedBox(
          width: 8,
        ),
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
      ],
    );
  }
}
