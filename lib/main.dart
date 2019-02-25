//import 'package:emrals/screens/onboard_screen.dart';
import 'package:emrals/screens/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:emrals/routes.dart';
import 'package:emrals/styles.dart';
import 'package:sentry/sentry.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:emrals/screens/home_screen.dart';
import 'package:emrals/state_container.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:emrals/data/rest_ds.dart';
import 'package:emrals/data/database_helper.dart';

//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

final SentryClient sentry = new SentryClient(
  dsn: "SENTRY_DSN",
  environmentAttributes: const Event(
    release: 'APP_VERSION_NUMBER (BUILD_NUMBER)',
  ),
);

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

void main() async {
  //debugPaintSizeEnabled = true;
  //debugPaintLayerBordersEnabled = true;
  //debugPaintPointersEnabled = true;
  //debugPaintBaselinesEnabled = true;
  //debugRepaintRainbowEnabled = true;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  if (Platform.isIOS) iOSPermission();

  String udid = await FlutterUdid.udid;
  String deviceType = Platform.isIOS ? "ios" : "android";

  DatabaseHelper().getUser().then((user) {
    if (user != null) {
      _firebaseMessaging.getToken().then((token) {
        RestDatasource().registerFCM(user.token, token, udid, deviceType);
      });
    }
  });

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
    },
    onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
    },
    onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
    },
  );

  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    runApp(
      StateContainer(
        child: MaterialApp(
          home: (!(preferences.getBool("onboarded") ?? false))
              ? OnboardScreen()
              : MyHomePage(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.black,
            primarySwatch: emralsColor(),
            fontFamily: 'Montserrat',
          ),
          routes: routes,
        ),
      ),
    );
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  if (isInDebugMode) {
    print(stackTrace);
    return;
  }

  sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );
}
