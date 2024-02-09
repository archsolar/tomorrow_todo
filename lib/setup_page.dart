// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/clock_widget.dart';
import 'package:tomorrow_todo/main.dart';

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
