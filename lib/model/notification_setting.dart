import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationSetting {
  int id;
  bool value;
  String name;
  IconData iconData;

  NotificationSetting(
      {required this.id,
      required this.value,
      required this.name,
      required this.iconData});
}

List<NotificationSetting> getListNotificationSetting() {
  return [
    NotificationSetting(
        id: 0,
        value: true,
        name: "Suara Azan",
        iconData: FontAwesomeIcons.volumeHigh),
    NotificationSetting(
        id: 1,
        value: false,
        name: "Tanpa Suara",
        iconData: FontAwesomeIcons.volumeOff)
  ];
}
