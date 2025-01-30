import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_prayer/common/adhan_dio.dart';
import 'package:my_prayer/domain/adhnan/create_prayers_notification.dart';
import 'package:my_prayer/domain/adhnan/month_prayers.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/domain/adhnan/current_prayer.dart';
import 'package:my_prayer/features/home/home_page.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/services/notification.dart';
import 'package:my_prayer/services/scheduler.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:my_prayer/utils/prefes_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_prayer/features/home/home_view_model.dart';

void main() async {
  // await dotenv.load(fileName: "assets/.env");

  await init();

  AdhanClientDio adhan = AdhanClientDio();

  CreatePrayerNotification createPrayerNotification =
      CreatePrayerNotification();

  GetMonthPrayer getMonthPrayer = GetMonthPrayer(adhan);
  GetTodayPrayer getTodayPrayer = GetTodayPrayer(adhan);

  await Scheduler().initScheduler();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (_) => HomeViewModel(
            PermissionUtils(),
            getTodayPrayer,
            GetCurrentPrayerUseCases(),
            createPrayerNotification,
            getMonthPrayer))
  ], child: const MyApp()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await hiveInit();

  await PrefesUtils.init();
  await AndroidAlarmManager.initialize();
  await NotificationServive.initialize();

  // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
}

Future<void> hiveInit() async {
  Directory dir = await getApplicationDocumentsDirectory();

  Hive.init(dir.path);

  Hive.registerAdapter(PrayerDbAdapter());
  Hive.registerAdapter(PrayerModelAdapter());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = 'My Prayer';
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: title));
  }
}
