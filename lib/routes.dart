import 'package:flutter/material.dart';
import 'package:emrals/screens/home_screen.dart';
import 'package:emrals/screens/login_screen.dart';
import 'package:emrals/screens/signup_screen.dart';
import 'package:emrals/screens/settings.dart';
import 'package:emrals/screens/camera.dart';

final routes = {
  '/login': (BuildContext context) => new LoginScreen(),
  '/signup': (BuildContext context) => new SignupScreen(),
  '/home': (BuildContext context) => new MyHomePage(),
  '/settings': (BuildContext context) => new Settingg(),
  '/camera': (BuildContext context) => new CameraApp(),
  '/': (BuildContext context) => new LoginScreen(),
};
