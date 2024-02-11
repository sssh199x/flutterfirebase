import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterfirebase/notification_services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission(context);
    notificationServices.foregroundMessageForIos();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractedMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print('Device Token:');
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Flutter Notifications'),
      ),
      body: Center(
          child: TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black12)),
              onPressed: () {
                notificationServices.getDeviceToken().then((value) async {
                  var data = {
                    'priority': 'high',
                    'to': value,
                    'notification': {
                      'body': 'Are you lost?',
                      'title': 'Hey! Baby Girl?'
                    },
                    // payload data
                    'data': {
                      // extra data defined by myself
                      'click_action': 'FLUTTER_NOTIFICATION_CLICK',

                      'type': 'message',
                      'id': '1234',
                      // extra data defined by myself
                      'status': 'done'
                    }
                  };
                  await http.post(
                    Uri.parse('https://fcm.googleapis.com/fcm/send'),
                    body: jsonEncode(data),
                    headers: {
                      'Content-Type': 'application/json; charset=UTF-8',
                      // This is the server key from firebase console
                      'Authorization':
                          'key=AAAAUtXr9k4:APA91bGa1c10c4QqAGKdKx1uw7gYCpk3qtR4AeyBO0aaCut7PP9FMHHPEjPp0yuR2L1LXxhA7hsT5cxBtpcHMdaxXhDsGtuZBbJbnxrkruqM-8gss8v2l-Z95A5VeGj4pzM22rww558f'
                    },
                  );
                });
              },
              child: const Text('Send Notifications'))),
    );
  }
}
