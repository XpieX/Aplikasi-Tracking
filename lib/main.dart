import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracking_app/screen/login_screen.dart';
import 'package:tracking_app/screen/navigation_screen.dart';
import 'package:tracking_app/service/auth_service.dart';
import 'package:tracking_app/utils/appcolor.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLoggedIn = await AuthService.isLoggedIn();
  final userId = await AuthService.getUserId();
  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int? userId;

  const MyApp({super.key, required this.isLoggedIn, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Kasir',

      theme: ThemeData(
        appBarTheme: AppBarTheme(color: AppColor.backgroundColorPrimary),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColor.backgroundColorPrimary,
      ),
      home: isLoggedIn && userId != null ? NavigationScreen() : LoginScreen(),
    );
  }
}
