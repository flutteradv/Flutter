import 'package:emrals/data/rest_ds.dart';
import 'package:flutter/material.dart';
import 'package:emrals/routes.dart';
import 'package:emrals/styles.dart';
import 'package:sentry/sentry.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:emrals/screens/home_screen.dart';
import 'dart:io';

final SentryClient sentry = new SentryClient(dsn: "SENTRY_DSN");

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

void main() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  if (Platform.isIOS) iOSPermission();

  _firebaseMessaging.getToken().then((token) {
    print(token);
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
    runApp(EmralsApp());
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');

  if (isInDebugMode) {
    print(stackTrace);
    return;
  }

  final SentryResponse response = await sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}

class EmralsApp extends StatefulWidget {
  @override
  EmralsAppState createState() {
    return EmralsAppState();
  }
}

class EmralsAppState extends State<EmralsApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: emralsColor(),
        fontFamily: 'Montserrat',
      ),
      routes: routes,
    );
  }
}
