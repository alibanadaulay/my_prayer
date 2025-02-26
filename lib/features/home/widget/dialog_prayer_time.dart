import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_prayer/model/notification_setting.dart';

class DialogPrayerTime extends StatelessWidget {
  DialogPrayerTime(
      {super.key,
      required this.onConfirm,
      required this.isSound,
      required this.prayerName});
  final bool isSound;
  final String prayerName;
  final Function(bool) onConfirm;
  final List<NotificationSetting> notificationSettings =
      getListNotificationSetting();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Text(
            "Pengaturan Notifikasi $prayerName",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(
            height: 8.0,
          ),
          Divider(),
          SizedBox(
            height: 8.0,
          ),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notificationSettings.length,
              itemBuilder: (context, index) {
                NotificationSetting item = notificationSettings[index];
                return Container(
                  margin: EdgeInsets.only(top: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      onConfirm(item.value);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: getPrayerColor(context, item.value == isSound),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            item.iconData,
                            size: 24.0,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: item.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium))
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
