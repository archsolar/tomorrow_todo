// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_game/clock_widget.dart';

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
                          "1 - You have to finish at least 1 task before the day ends... or the app will be disabled"),
                      RuleText(
                          "2 - Every task needs to be marked as complete before the day ends... or the app will be disabled"),
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

class Page2 extends ConsumerWidget {
  const Page2({super.key});
  Widget currentPage() {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day);
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("It's currently:"),
            // TODO add this to preferences.
            ClockWidget(
              switchEnabled: false,
              clockEnabled: true,
            ),
            Text("The deadline is:"),
            TimeDisplay(displayTime: midnight),
            ClockWidget(
              switchEnabled: true,
              clockEnabled: false,
            ),
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
