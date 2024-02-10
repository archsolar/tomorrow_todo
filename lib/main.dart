// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/daily_page.dart';
import 'package:tomorrow_todo/settings.dart';
import 'package:tomorrow_todo/setup_page.dart';
import 'package:tomorrow_todo/util.dart';
import 'providers.dart';

final isTaskEmpty = StateProvider<bool>((ref) {
  return tasks.isEmpty;
});

Future<void> main() async {
  await beforeRunApp();
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

class RuleText extends StatelessWidget {
  final String text;

  const RuleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class BasicPage extends ConsumerWidget {
  final Widget currentPage;
  final ConsumerWidget? nextPage;
  // final String text;
  final String buttonText;
  const BasicPage(
      {super.key,
      required this.currentPage,
      required this.nextPage,
      required this.buttonText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40), // Adjust the spacing as needed
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: currentPage),
          SizedBox(height: 16), // Adjust the spacing as needed
          SizedBox(
            height: 50, // Adjust the height as needed
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO lots of work here
                if (nextPage == null) {
                  // Move on to the main page.
                  // TODO SETUP BASIC TASK.
                } else {
                  // TODO how to correctly change this without using the notivier state thing.
                  final nav =
                      ref.read(navigationProvider.notifier).push(nextPage!);
                }
              },
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
