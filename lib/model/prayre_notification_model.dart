class PrayreNotificationModel {
  int id;
  DateTime dateTime;
  bool isSound;
  String soundName;
  String name;
  String time;

  PrayreNotificationModel(
      {required this.id,
      required this.dateTime,
      required this.isSound,
      required this.name,
      required this.time,
      required this.soundName});
}
