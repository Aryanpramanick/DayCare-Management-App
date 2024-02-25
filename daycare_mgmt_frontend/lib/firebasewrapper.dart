import 'dart:async';

import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:firebase_messaging/firebase_messaging.dart';

class CallBackInterface {
  void update() {}
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class FirebaseWrapper {
  static final FirebaseWrapper _singleton = FirebaseWrapper._internal();
  late StreamSubscription<RemoteMessage> msgCallback; //firebase messaging
  List<CallBackInterface> listeners = [];

  factory FirebaseWrapper() {
    return _singleton;
  }

  FirebaseWrapper._internal() {}

  void setupFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    token = await getFirebaseToken();

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await bindToken(uid, token);
    FirebaseMessaging.instance.setAutoInitEnabled(true);
    msgCallback = FirebaseMessaging.onMessage.listen(handleCallback);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String> getFirebaseToken() async {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken ?? "";
  }

  Future<void> bindToken(int userId, String token) async {
    try {
      final httpPackageUrl =
          Uri.http(url, '${'/api/bind_device/$userId'}/$token/');

      var httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': createAuth()});

      var tries = 0;
      while (httpPackageResponse.statusCode != 200 && tries < 5) {
        print("Retrying binding fcm token to user");
        httpPackageResponse = await http
            .get(httpPackageUrl, headers: {'authorization': createAuth()});
        tries++;
      }

      // Check response for success
      if (httpPackageResponse.statusCode == 200) {
        //for debugging
        print(httpPackageResponse.body);
      } else {
        print(httpPackageResponse.statusCode);
      }
    } catch (_) {
      print("Error binding fcm token to user");
      print(_);
    }
  }

  void registerCallback(CallBackInterface listener) {
    listeners.add(listener);
  }

  void unregisterCallback(CallBackInterface listener) {
    listeners.remove(listener);
  }

  void handleCallback(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      fln.FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        const fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'channel id',
            'description',
            icon: 'launch_background',
          ),
        ),
      );

      for (var listener in listeners) {
        listener.update();
      }
    }
  }

  Future<void> unbindToken(int userId, String token) async {
    try {
      final httpPackageUrl =
          Uri.http(url, '${'/api/unbind_device/$userId'}/$token/');

      var httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': createAuth()});

      var tries = 0;
      while (httpPackageResponse.statusCode != 200 && tries < 5) {
        print("Retrying binding fcm token to user");
        httpPackageResponse = await http
            .get(httpPackageUrl, headers: {'authorization': createAuth()});
        tries++;
      }

      // Check response for success
      if (httpPackageResponse.statusCode == 200) {
        //for debugging
        print(httpPackageResponse.body);
      } else {
        print(httpPackageResponse.statusCode);
      }
    } catch (_) {
      print("Error binding fcm token to user");
      print(_);
    }
  }

  void disposeFirebase() async {
    if (listeners.length == 0) {
      return;
    }
    for (int i = 0; i < listeners.length; i++) {
      var listener = listeners[i];
      unregisterCallback(listener);
    }
    msgCallback.cancel();
    await unbindToken(uid, token);
  }
}
