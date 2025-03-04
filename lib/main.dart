import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_prayer/common/adhan_dio.dart';
import 'package:my_prayer/domain/adhnan/create_prayer_notification.dart';
import 'package:my_prayer/domain/adhnan/create_prayers_notification.dart';
import 'package:my_prayer/domain/adhnan/month_prayers.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/domain/adhnan/current_prayer.dart';
import 'package:my_prayer/features/home/home_page.dart';
import 'package:my_prayer/model/db/prayer_db.dart';
import 'package:my_prayer/resources/theme.dart';
import 'package:my_prayer/services/notification.dart';
import 'package:my_prayer/services/scheduler.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:my_prayer/utils/prefes_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // await dotenv.load(fileName: "assets/.env");

  await init();

  // _firebaseErrorCatcher();

  AdhanClientDio adhan = AdhanClientDio();

  CreatePrayersNotification createPrayerNotification =
      CreatePrayersNotification();

  GetMonthPrayer getMonthPrayer = GetMonthPrayer(adhan);
  GetTodayPrayer getTodayPrayer = GetTodayPrayer(adhan);

  await Scheduler.initScheduler();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (_) => HomeViewModel(
              PermissionUtils(),
              getTodayPrayer,
              GetCurrentPrayerUseCases(),
              createPrayerNotification,
              getMonthPrayer,
              CreatePrayerNotification(),
            ))
  ], child: const MyApp()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase.initializeApp();

  await PrefesUtils.getInstance();
  await hiveInit();

  await AndroidAlarmManager.initialize();
  await NotificationService.initialize();
}

void _firebaseErrorCatcher() {
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
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
      themeMode: ThemeMode.system,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: const MyHomePage(title: title),
    );
  }
}
