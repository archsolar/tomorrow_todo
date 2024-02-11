// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ClockWidget extends ConsumerStatefulWidget {
  final bool switchEnabled;
  final bool clockEnabled;

  const ClockWidget(
      {super.key, required this.switchEnabled, required this.clockEnabled});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClockWidgetState();
}

final timeFormatProvider =
    NotifierProvider<TimeFormatNotifier, bool>(TimeFormatNotifier.new);

class TimeFormatNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  bool toggle() {
    state = !state;
    return state;
  }

  void set(bool value) {
    state = value;
  }

  bool get() {
    return state;
  }
}

class _ClockWidgetState extends ConsumerState<ClockWidget> {
  DateTime selectedTime = DateTime.now();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        print("A");
        selectedTime = DateTime.now(); // Update the time every minute
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeformat = ref.read(timeFormatProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.clockEnabled
              ? TimeDisplay(displayTime: selectedTime)
              : Container(),
          widget.switchEnabled
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('24-Hour Format'),
                    Switch(
                      value: ref.watch(timeFormatProvider),
                      onChanged: (value) {
                        print("toggles");
                        ref.read(timeFormatProvider.notifier).state =
                            value; // Directly set the new state
                      },
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

Text bigText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 48, // Adjust the font size as needed
      fontWeight: FontWeight.bold,
    ),
  );
}

class TimeDisplay extends ConsumerWidget {
  final DateTime displayTime;
  const TimeDisplay({super.key, required this.displayTime});

  String _formattedTime(DateTime time, bool timeformat) {
    // Format time based on the switch's state
    return DateFormat(timeformat ? 'HH:mm' : 'hh:mm a').format(displayTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeformat = ref.watch(timeFormatProvider);
    return bigText(_formattedTime(displayTime, timeformat));
  }
}
