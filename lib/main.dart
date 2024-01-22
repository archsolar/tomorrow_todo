// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/daily_page.dart';
import 'package:tomorrow_todo/settings.dart';
import 'package:tomorrow_todo/util.dart';
import 'providers.dart';

var dateCode = 'dd-MM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();
  // Set riverpod globals, so they'll be lazy loaded later.
  await setGlobalPref();
  tasks = await Database.getAllTasks();
  runApp(ProviderScope(
    child: AppWrap(),
  ));
}

class AppWrap extends ConsumerWidget {
  const AppWrap({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var preference = ref.watch(preferenceProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: getTextTheme(preference.fontSize, preference.font),
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: getTextTheme(preference.fontSize, preference.font)),
      themeMode: (preference.darkMode ? ThemeMode.dark : ThemeMode.light),
      debugShowCheckedModeBanner: false,
      home: DailyPage(title: 'Tomorrow TODO'),
    );
  }
}