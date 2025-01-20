import 'package:flutter/material.dart';
import 'package:my_prayer/domain/adhnan/today_prayers.dart';
import 'package:my_prayer/features/home/home_page.dart';
import 'package:my_prayer/utils/permission_utils.dart';
import 'package:provider/provider.dart';
import 'package:my_prayer/features/home/home_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async{
  // await dotenv.load(fileName: "assets/.env");

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel(PermissionUtils(), GetTodayPrayer()))],
      child: const MyApp()));
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
