// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/daily_page.dart';
import 'package:tomorrow_todo/settings.dart';
import 'package:tomorrow_todo/setup_widget.dart';
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
    final widget = ref.watch(currentSetupWidget);
    return Scaffold(body: widget);
  }
}

final currentSetupWidget = StateProvider<ConsumerWidget>((ref) {
  return Page1();
});

class Page1 extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text("Page1"),
        ElevatedButton(
            onPressed: () {
              // Navigate to Page2
              ref.read(currentSetupWidget.notifier).state = Page2();
              //TODO how to go back to Page1?
            },
            child: Text("Continue to page2"))
      ],
    );
  }
}

class Page2 extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return Text("Page2");
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
      themeMode: (preference.darkMode ? ThemeMode.dark : ThemeMode.light),
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
// 2. Setup fair end of day. "Tomorrow stars at: "
// 3. Setup remainders. "1 time at timestamp or custom"
// 4. Would you want to enable other features? Journalling/end of day rating/
// 5. You can now set tasks for tomorrow.
// final widgetProvider = StateProvider<PagesWidget>((ref) => Page1());

// class SetupParent extends ConsumerWidget {
//   const SetupParent({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final widget = ref.watch(widgetProvider);
//     return Scaffold(
//         body: BasicPage(
//       currentPage: widget,
//       nextPage: widget.next,
//       buttonText: widget.buttonText,
//     ));
//   }
// }

// abstract class PagesWidget extends ConsumerWidget {
//   final Widget next;
//   final String buttonText;

//   const PagesWidget({Key? key, required this.next, required this.buttonText})
//       : super(key: key);
// }

// class Page1 extends PagesWidget {
//   Page1({super.key})
//       : super(
//           next:
//               Page2(), // Replace YourWidget with the widget you want to assign
//           buttonText: "I agree",
//         );

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 16), // Adding some spacing
//           // Container with rules
//           Center(
//             child: Container(
//               padding: EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromARGB(255, 207, 35, 136),
//                     Colors.purple,
//                     const Color.fromARGB(255, 53, 39, 176)
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 20, 17, 17),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     RuleText(
//                         "1 - You need to finish all tasks before the day ends or your app will be disabled."),
//                     RuleText(
//                         "2 - There needs to be at least one continuous task by default: [add tasks for tomorrow]"),
//                     RuleText("3 - Everything is stored locally."),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RuleText extends StatelessWidget {
//   final String text;

//   const RuleText(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
// }

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

// class Page3 extends StatelessWidget {
//   const Page3({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// class BasicPage extends ConsumerWidget {
//   final Widget currentPage;
//   final Widget? nextPage;
//   // final String text;
//   final String buttonText;
//   const BasicPage(
//       {super.key,
//       required this.currentPage,
//       required this.nextPage,
//       required this.buttonText});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Column(
//       children: [
//         SizedBox(height: 40), // Adjust the spacing as needed
//         SizedBox(
//             height: MediaQuery.of(context).size.height * 0.7,
//             child: currentPage),
//         SizedBox(height: 16), // Adjust the spacing as needed
//         SizedBox(
//           height: 50, // Adjust the height as needed
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () {
//               // TODO lots of work here
//               if (nextPage == null) {
//                 // Move on to the main page.
//               } else {
//                 // TODO how to correctly change this without using the notivier state thing.
//                 final a = ref.read(widgetProvider) = Page2();
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(builder: (context) => nextPage!),
//                 // );
//                 ref.read();
//               }
//             },
//             child: Text(buttonText),
//           ),
//         ),
//       ],
//     );
//   }
// }
