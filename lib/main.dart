import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pool_mate/authentication/PhoneNumber.dart';
import 'package:pool_mate/authentication/OTPVerification.dart';
import 'package:pool_mate/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Verification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUpScreen(),
    );
  }
}
