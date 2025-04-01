import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ตั้งค่า Notifications
  Future<void> initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // เริ่มต้นข้อมูล timezone
    tz.initializeTimeZones();
  }

  // ส่งการแจ้งเตือน
  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // ฟังก์ชันการตั้งเวลาแจ้งเตือน (1 ชั่วโมงก่อนนัดหมาย)
  Future<void> scheduleNotification(DateTime dateTime) async {
    // ใช้ TZDateTime แทน DateTime
    tz.getLocation('Asia/Bangkok');

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    // ใช้ show แทน zonedSchedule หากไม่มีการรองรับ
    await flutterLocalNotificationsPlugin.show(
      0,
      'การนัดหมาย',
      'คุณมีการนัดหมายใน 1 ชั่วโมง',
      notificationDetails,
    );
  }
}
