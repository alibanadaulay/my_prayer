import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:my_prayer/features/home/widget/prayer_item.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HomeViewModel homeViewModel;

  @override
  void initState() {
    super.initState();
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          color: Colors.black38,
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[header(), todayPrayerWidget()],
    );
  }

  Widget header() {
    return Container(
      color: Colors.blueAccent,
      child: Column(
        children: [locationAndDateWidget(), currentPrayerWidget()],
      ),
    );
  }

  Widget locationAndDateWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              homeViewModel.setLocationName("Mampang, Jakarta Selatan");
            },
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: Colors.white54,
                  size: 20.0,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                dateText(
                  homeViewModel.locationName,
                ),
              ],
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                dateText(homeViewModel.arabicDate),
                dateText(homeViewModel.date,
                    textStyle:
                        const TextStyle(fontSize: 12, color: Colors.white)),
              ])
        ],
      ),
    );
  }

  Widget currentPrayerWidget() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        return Column(
          children: [
            RichText(
                text: TextSpan(
                    text: homeViewModel.currenPrayer,
                    style:
                        const TextStyle(fontSize: 24.0, color: Colors.white))),
            Text(homeViewModel.timePrayer),
            Text(homeViewModel.remainingTime),
          ],
        );
      },
    );
  }

  Widget todayPrayerWidget() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        return Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: homeViewModel.prayerTimes.length,
            itemBuilder: (context, index) {
              PrayerTime item = homeViewModel.prayerTimes[index];
              return PrayerItem(
                key: Key("$index"),
                name: item.name,
                time: item.time,
                isNextPrayer: item.isNextPrayer,
              );
            },
          ),
        );
      },
    );
  }

  RichText dateText(String value, {TextStyle? textStyle}) {
    return RichText(
      maxLines: 2,
      text: TextSpan(
        text: value,
        style: textStyle ??
            const TextStyle(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
      ),
    );
  }
}
