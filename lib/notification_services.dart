import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfirebase/message_screen.dart';

// Link to prevent auto initialization: https://firebase.google.com/docs/cloud-messaging/flutter/client#prevent-auto-init
// When an FCM registration token is generated, the library uploads the identifier and configuration data to Firebase. If you prefer to prevent token autogeneration, disable auto-initialization at build time.

// Re-enable FCM auto-init at runtime : To enable auto-init for a specific app instance, call setAutoInitEnabled():
// await FirebaseMessaging.instance.setAutoInitEnabled(true);
class NotificationServices {
  // To get a new instance of the FirebaseMessaging

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // To get a new instance of the Flutter Local Notifications Plugin

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    // Constructs an instance of [AndroidInitializationSettings].

    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    // Constructs an instance of [DarwinInitializationSettings].

    var iosInitializationSettings = const DarwinInitializationSettings();

    // Constructs an instance of [InitializationSettings].

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    // Initializes the plugin.Call this method on application before using the plugin further.

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      _handleMessages(context, message);
    });
  }

  void _handleMessages(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'message') {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageScreen(id: message.data['id']),
          ));
    }
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    // If the message also contains a data property with a "type" of "message", navigate to a message screen.
    if (initialMessage != null) {
      if (context.mounted) {
        _handleMessages(context, initialMessage);
      }

      // If i uncomment this it would say : Don't use 'BuildContext's across async gaps.Try rewriting the code to not reference the 'BuildContext'. And to solve this warning we must check to see if the context is mounted or not,which is done above.
      // handleMessages(context, initialMessage);
    }
    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(
      (event) => _handleMessages(context, event),
    );
  }

  Future<void> showNotifications(RemoteMessage message) async {
    // Android Notification Channel

    AndroidNotificationChannel channel = const AndroidNotificationChannel(
        // high_importance_level is the value that i have used in the metadata parameter of androidmanifest file so i am using it as the channel id.
        "high_importance_level",
        'High Importance Channel',
        // If this is set to anyother than max then the notifications wouldnt be shown in the UI
        importance: Importance.max,
        description: 'Your Channel Description');

    // Android Notification Details

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: channel.description,
      // make sure this is only set to high
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  void firebaseInit(BuildContext context) {
    // To handle messages while your application is in the foreground, listen to the onMessage stream.

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        // This message.data is called the payload.You can send the extra data that is required. It stores value in the form of key and value
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotifications(message);
      } else {
        showNotifications(message);
      }
    });
  }

  void requestNotificationPermission(BuildContext context) async {
    // Prompts the user for notification permissions.
    // Note that on iOS, if [provisional] is set to true, silent notification permissions will be automatically granted. When notifications are delivered to the device, the user will be presented with an option to disable notifications, keep receiving them silently or enable prominent notifications.
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user acces granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      print('user permission not determined');
    } else {
      print('user permission denied');
      _showSettingsDialog(context);
    }
  }

  // This works for both ios and android
  Future<String> getDeviceToken() async {
    // Returns the default FCM token for this device.On web, a [vapidKey] is required.
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    // Fires when a new FCM token is generated.
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Token Refreshed');
    }).onError((error) {
      print('Error for not getting  refreshed token: $error');
    });
  }

  // Show dialog to guide the user to open settings
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notification Permission Denied"),
          content: const Text(
              "To enable notifications, please go to Settings and allow notifications for this app."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Open app settings
  void _openAppSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
}
