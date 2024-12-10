import 'package:flutter/material.dart';
import 'package:my_prayer/features/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:my_prayer/features/home/home_view_model.dart';

void main() {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeViewModel())],
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
