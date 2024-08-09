import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'timezone_helper.dart';

void main() {
  initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatefulWidget {
  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  String? selectedDay;
  TimeOfDay? selectedTime;
  String? selectedActivity;

  final List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> activities = [
    'Wake up', 'Go to gym', 'Breakfast', 'Meetings', 'Lunch',
    'Quick nap', 'Go to library', 'Dinner', 'Go to sleep'
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification() async {
    var now = tz.TZDateTime.now(tz.local);
    var nextReminder = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + _daysUntilNext(selectedDay!),
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (nextReminder.isBefore(now)) {
      nextReminder = nextReminder.add(Duration(days: 7));
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'reminder_channel',
        'Reminder Notifications',
        channelDescription: 'Channel for Reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker'
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        'Time to $selectedActivity',
        nextReminder,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  int _daysUntilNext(String day) {
    final now = DateTime.now();
    final targetDay = daysOfWeek.indexOf(day);
    final today = now.weekday - 1; // DateTime.weekday returns 1 for Monday, 7 for Sunday

    if (targetDay >= today) {
      return targetDay - today;
    } else {
      return 7 - (today - targetDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              hint: Text('Select Day of the Week'),
              value: selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              },
              items: daysOfWeek.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                setState(() {
                  selectedTime = time;
                });
              },
              child: Text(selectedTime != null
                  ? selectedTime!.format(context)
                  : 'Select Time'),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              hint: Text('Select Activity'),
              value: selectedActivity,
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: activities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (selectedDay != null && selectedTime != null && selectedActivity != null) {
                  _scheduleNotification();
                }
              },
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
