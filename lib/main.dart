// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_game/components/database.dart';
import 'package:todo_game/pages/daily_page.dart';
import 'package:todo_game/pages/settings.dart';
import 'package:todo_game/pages/setup_page.dart';
import 'package:todo_game/components/util.dart';
import 'components/providers.dart';

final isTaskEmpty = StateProvider<bool>((ref) {
  return tasks.isEmpty;
});

Future<void> main() async {
  await beforeRunApp();
  NotificationService().init();
  runApp(ProviderScope(
    child: AppWrap(StartupWidget() /* SetupParent() */),
  ));
}

class StartupWidget extends ConsumerWidget {
  const StartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskEmpty = ref.watch(isTaskEmpty);

    return taskEmpty
        ? AppWrap(SetupPage())
        : AppWrap(DailyPage(title: 'Tomorrow TODO'));
  }
}

Future<void> beforeRunApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();
  // Set riverpod globals, so they'll be lazy loaded later.
  await setGlobalPref();
  tasks = await Database.getAllTasks();
}

class AppWrap extends ConsumerWidget {
  const AppWrap(this.widget, {super.key});
  final Widget widget;

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
      // IDEA only dark mode now will change.
      themeMode: (preference.darkMode ? ThemeMode.dark : ThemeMode.dark),
      debugShowCheckedModeBanner: false,
      home: widget,
    );
  }
}
// 0. Here are the rules:
// - you need to finish all tasks before the day ends or your app will be disabled.
// - there will be up to 5 user tasks every day.
// - at the start of each day a task will be added called: add tasks for tomorrow unless all tomorrow's task slots are occupied.
// - everything is stored locally.

// 1. Display Today's date + timezone. "Today: "
// x. Setup colors
// 2. Setup fair end of day. "Tomorrow stars at: " Make sure to allow alerts
// 3. Setup remainders. "1 time at timestamp or custom"
// 4. Would you want to enable other features? Journalling/end of day rating/
// 5. You can now set tasks for tomorrow.
// final widgetProvider = StateProvider<PagesWidget>((ref) => Page1());

