import 'package:buyer_centric_app_v2/screens/home_screen.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
