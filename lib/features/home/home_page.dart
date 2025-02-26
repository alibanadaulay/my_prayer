import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:my_prayer/features/home/widget/prayer_item.dart';
import 'package:my_prayer/features/state_ui.dart';
import 'package:my_prayer/model/prayer_time.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late HomeViewModel homeViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (appLifecycleState == AppLifecycleState.resumed) {
      homeViewModel.recalculatedRemainingPrayerTime();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[_header(), _todayPrayerWidget()],
    );
  }

  Widget _header() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Theme.of(context).brightness == Brightness.dark
                  ? "assets/masjid_dark.png"
                  : "assets/masjid_light.png"),
              fit: BoxFit.fitWidth)),
      child: Column(
        children: [locationAndDateWidget(), currentPrayerWidget()],
      ),
    );
  }

  Widget locationAndDateWidget() {
    return Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final bool result = await PermissionUtils().requestPermission();
                if (result) {
                  homeViewModel.setNewLocation();
                } else {
                  Permission.location.onGrantedCallback(() {
                    homeViewModel.setNewLocation();
                  });
                  Permission.location.request();
                }
              },
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 24.0,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  RichText(
                    text: TextSpan(
                        text: homeViewModel.locationName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(letterSpacing: 1)),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 24.0),
              child: dateText(homeViewModel.arabicDate,
                  textStyle: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w200)),
            ),
          ],
        ),
      );
    });
  }

  Widget currentPrayerWidget() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        return Container(
          margin: EdgeInsets.only(top: 32),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  text: homeViewModel.currenPrayer,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              RichText(
                text: TextSpan(
                    text: homeViewModel.timePrayer,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 36.0)),
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: RichText(
                  text: TextSpan(
                      text: homeViewModel.remainingTime,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 24.0)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _todayPrayerWidget() {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        switch (homeViewModel.prayerListState) {
          case ViewState.loading:
          default:
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.zero,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: homeViewModel.prayerTimes.length,
                  itemBuilder: (context, index) {
                    PrayerTimeModel item = homeViewModel.prayerTimes[index];
                    return PrayerItem(
                      key: Key("${item.id}"),
                      id: item.id,
                      isSound: item.isSound,
                      name: item.name,
                      time: item.time,
                      isNextPrayer: item.isNextPrayer,
                      isFirst: index == 0,
                      isLast: index == homeViewModel.prayerTimes.length - 1,
                    );
                  },
                ),
              ),
            );
        }
      },
    );
  }

  RichText dateText(String value, {TextStyle? textStyle}) {
    return RichText(
      maxLines: 2,
      text: TextSpan(
        text: value,
        style: textStyle ??
            const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
