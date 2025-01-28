class PrayreNotificationModel {
  int id;
  DateTime dateTime;
  bool isSound;
  String soundName;
  String name;

  PrayreNotificationModel(
      {required this.id,
      required this.dateTime,
      required this.isSound,
      required this.name,
      required this.soundName});
}
