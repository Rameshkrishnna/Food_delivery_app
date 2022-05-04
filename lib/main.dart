import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smack/Screens/address.dart';
import 'package:smack/Screens/home.dart';
import 'package:smack/Screens/notificaton.dart';
import 'package:smack/Screens/orders.dart';
import 'package:smack/Screens/profile.dart';
import 'package:smack/Screens/register.dart';
import 'package:smack/Utilities/consta.dart';
import 'Screens/cart.dart';
import 'Screens/home.dart';
import 'Screens/hotel.dart';
import 'Screens/login.dart';
import 'Screens/splash.dart';
import 'Screens/search.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print(message.data);
  flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
            sound: RawResourceAndroidNotificationSound("softbell"),
            playSound: true,
        ),
      ));
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, channel.description,
                  icon: android?.smallIcon,
                  sound: RawResourceAndroidNotificationSound("softbell"),
                  playSound: true),
            ));
      }
    });
    getToken();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Lato',
        primaryColor: primarycolor,
      ),
      //color: primaryClr,
      debugShowCheckedModeBanner: false,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        AddressScreen.id: (context) => AddressScreen(),
        HotelScreen.id: (context) => HotelScreen(),
        CartScreen.id: (context) => CartScreen(),
        OrdersScreen.id: (context) => OrdersScreen(),
        NotificationScreen.id: (context) => NotificationScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        RegisterScreen.id: (context) => RegisterScreen()
      },
      initialRoute: SplashScreen.id,
    );
  }

  getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    print('token=$token');
  }
}
