import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Todo {
  final String title;
  final DateTime dueDate;

  Todo({
    required this.title,
    required this.dueDate,
  });
}

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TodoProvider() {
    _initializeNotifications();
  }

  List<Todo> get todos => _todos;

  void addTodo(String title, DateTime dueDate) {
    final todo = Todo(
      title: title,
      dueDate: dueDate,
    );
    _todos.add(todo);
    _scheduleNotification(todo);
    notifyListeners();
  }

  void removeTodoAt(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }

  void _initializeNotifications() {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(settings);

    tz.initializeTimeZones();
  }

  void _scheduleNotification(Todo todo) async {
    final scheduledDate = tz.TZDateTime.from(todo.dueDate.subtract(Duration(minutes: 5)), tz.local);
    const androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'To-Do Notifications',
      channelDescription: 'Notifications for To-Do App',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      todo.dueDate.hashCode,
      'Upcoming Task',
      'You have a task "${todo.title}" due soon!',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
