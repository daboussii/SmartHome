import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken'); // Ajoutez cette ligne pour imprimer le token

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
