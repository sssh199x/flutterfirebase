import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

// Link to prevent auto initialization: https://firebase.google.com/docs/cloud-messaging/flutter/client#prevent-auto-init
// When an FCM registration token is generated, the library uploads the identifier and configuration data to Firebase. If you prefer to prevent token autogeneration, disable auto-initialization at build time.

// Re-enable FCM auto-init at runtime : To enable auto-init for a specific app instance, call setAutoInitEnabled():
// await FirebaseMessaging.instance.setAutoInitEnabled(true);
class NotificationServices {
  // To get a new instance of the FirebaseMessaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

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
