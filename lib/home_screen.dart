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
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
