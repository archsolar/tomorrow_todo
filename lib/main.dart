// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/clock_widget.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/daily_page.dart';
import 'package:tomorrow_todo/settings.dart';
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

class SetupPage extends ConsumerWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPageWidget = ref.watch(navigationProvider);
    return Scaffold(body: currentPageWidget.last);
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, List<ConsumerWidget>>(
        NavigationNotifier.new);

class NavigationNotifier extends Notifier<List<ConsumerWidget>> {
  @override
  List<ConsumerWidget> build() => [Page1()];

  void push(ConsumerWidget page) {
    state = [...state, page];
  }

  bool pop() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
      return true; // Indicate success
    }
    return false; // Nothing to pop
  }
}

class Page1 extends ConsumerWidget {
  Widget currentPage() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16), // Adding some spacing
            // Container with rules
            Center(
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 207, 35, 136),
                      Colors.purple,
                      const Color.fromARGB(255, 53, 39, 176)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 20, 17, 17),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RuleText(
                          "1 - You need to finish all tasks before the day ends or your app will be disabled."),
                      RuleText(
                          "2 - There needs to be at least one continuous task \nDefault: [add tasks for tomorrow]"),
                      RuleText(
                          "3 - Everything is stored locally, there is no cloud."),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget build(BuildContext context, WidgetRef ref) {
    return BasicPage(
      buttonText: "I agree",
      currentPage: currentPage(),
      nextPage: Page2(),
    );
  }
}

class Page2 extends ConsumerWidget {
  const Page2({super.key});
  Widget currentPage() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("It's currently:"),
            // TODO add this to preferences.
            ClockWidget(),
            Text("I'm productive until (deadline):"),
          ],
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasicPage(
      buttonText: "Continue",
      currentPage: currentPage(),
      nextPage: Page3(),
    );
  }
}

class Page3 extends ConsumerWidget {
  const Page3({super.key});
  Widget currentPage() {
    return Padding(
        padding: const EdgeInsets.all(20.0), child: Text("Setup colors "));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasicPage(
      buttonText: "Next setup reminders",
      currentPage: currentPage(),
      nextPage: Page4(),
    );
  }
}

class Page4 extends ConsumerWidget {
  const Page4({super.key});
  Widget currentPage() {
    return Padding(
        padding: const EdgeInsets.all(20.0), child: Text("Setup reminders"));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasicPage(
      buttonText: "Continue",
      currentPage: currentPage(),
      nextPage: Page5(),
    );
  }
}

class Page5 extends ConsumerWidget {
  const Page5({super.key});
  Widget currentPage() {
    return Padding(
        padding: const EdgeInsets.all(20.0), child: Text("optional features"));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasicPage(
      buttonText: "Continue",
      currentPage: currentPage(),
      nextPage: Page6(),
    );
  }
}

class Page6 extends ConsumerWidget {
  const Page6({super.key});
  Widget currentPage() {
    return Padding(
        padding: const EdgeInsets.all(20.0), child: Text("All set!"));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasicPage(
      buttonText: "Good luck [demonic wink]",
      currentPage: currentPage(),
      nextPage: null,
    );
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

// class Page2 extends PagesWidget {
//   Page2({super.key})
//       : super(
//           next:
//               Page2(), // Replace YourWidget with the widget you want to assign
//           buttonText: "I agree",
//         );

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return BasicPage(
//         currentPage: main(context), nextPage: Page3(), buttonText: "continue");
//   }

//   Widget main(BuildContext context) {
//     var dateCode = 'HH:mm';
//     var date = DateFormat(dateCode).format(DateTime.now());

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color.fromARGB(255, 20, 17, 17),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//           child: Column(
//         children: [
//           RuleText("1 - Current time: $date"),
//         ],
//       )),
//     );
//   }
// }

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
