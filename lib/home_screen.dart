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
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print('Device Token:');
      print(value);
    });
  }

// exAAmliwTwCHc8PtP1SUht:APA91bEfV-qWv-0fLKnmfekjFtCfZg8X0vpSBBM4RP0GXgDovwOGE3Bx20FqwrNT03XYKmcjwMaAMO-VnTVu7Wni-0oEsTTtSGFm4f-LFG3Pxo_7H-Ba-Bl3T0SlBhjJFrruk9yamLF5
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
