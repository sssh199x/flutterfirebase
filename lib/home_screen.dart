import 'package:flutter/material.dart';
import 'package:flutterfirebase/notification_services.dart';

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
    notificationServices.firebaseInit();
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
    );
  }
}
