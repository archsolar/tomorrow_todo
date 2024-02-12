import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    //TODO check if already init;
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'todogame');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
      linux: initializationSettingsLinux,
    );
    //TODO timezones need thinking.
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<void> addFinishTaskNotification(
      int hour, int minute, int id) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'task_finish_channel_id', 'Task Finish Channel',
        importance: Importance.max, priority: Priority.high, showWhen: true);

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    final scheduledDate = _convertTime(hour, minute);
    await scheduleNotification(id, scheduledDate, platformChannelSpecifics);
  }

  /// Set right date and time for notifications
  static tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  static Future<void> scheduleNotification(int id, tz.TZDateTime scheduledDate,
      NotificationDetails platformChannelSpecifics) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, 'Task Reminder', 'Time to finish a task!',
      // Notification in 5 seconds.
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode
          .alarmClock, // Ensure the notification is shown even if the phone is in a low-power idle mode
      matchDateTimeComponents: DateTimeComponents
          .time, // Match on time component only for daily recurrence
      payload: 'todo payload',
    );
    _zonedScheduleAlarmClockNotification();
  }

  static Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> _zonedScheduleAlarmClockNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        123,
        'scheduled alarm clock title',
        'scheduled alarm clock body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'alarm_clock_channel', 'Alarm Clock Channel',
                channelDescription: 'Alarm Clock Notification')),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}

// This is called before addFinishTaskNotification
Future<bool> requestExactAlarmPermission() async {
  var status = await Permission.scheduleExactAlarm.status;
  if (!status.isGranted) {
    final result = await Permission.scheduleExactAlarm.request();
    if (result.isGranted) {
      // Permission granted
      return true;
    } else {
      // Handle permission denied
      return false;
    }
  }
  return true;
}
