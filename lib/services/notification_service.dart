import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'konfeti_ticket_channel',
        'Notifikasi Konfeti',
        channelDescription: 'Pemberitahuan pemesanan tiket dan pengingat konser',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    int id = 1,
  }) async {
    await init();
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await init();

    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime.from(scheduledDate, tz.local);
    if (!target.isAfter(now)) target = now.add(const Duration(seconds: 10));

    Future<void> schedule(AndroidScheduleMode mode) {
      return _notificationsPlugin.zonedSchedule(
        id: id,
        scheduledDate: target,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: mode,
        title: title,
        body: body,
      );
    }

    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException {
      // Izin alarm tepat waktu ditolak sistem: pakai mode tidak tepat agar tetap muncul.
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }
}
