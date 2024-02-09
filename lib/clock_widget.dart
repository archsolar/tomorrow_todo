// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ClockWidget extends StatefulWidget {
  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

// TODO make this into a provider in preferences?
bool is24HourFormat = false; // Switch state

class _ClockWidgetState extends State<ClockWidget> {
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
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        selectedTime = DateTime.now(); // Update the time every minute
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formattedTime(),
            style: TextStyle(
              fontSize: 48, // Adjust the font size as needed
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('24-Hour Format'),
              Switch(
                value: is24HourFormat,
                onChanged: (value) {
                  setState(() {
                    is24HourFormat = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formattedTime() {
    var now = DateTime.now();
    // Format time based on the switch's state
    return DateFormat(is24HourFormat ? 'HH:mm' : 'hh:mm a').format(now);
  }
}
