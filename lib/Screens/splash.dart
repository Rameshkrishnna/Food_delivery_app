import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loca;

class SplashScreen extends StatefulWidget {
  static const String id = "SplashScreen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String password, mob, token;
  String loadtxt = '';
  double loadint = 0.0;

  @override
  void initState(){
    super.initState();
    connection();
    _loca();
    new Timer(const Duration(seconds: 5), onClose);
  }

  _loca()async{
    bool _serviceEnabled;
    loca.PermissionStatus _permissionGranted;
    loca.Location location = new loca.Location();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loca.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loca.PermissionStatus.granted) {
      }
    }
  }
  connection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none) {
      final snackBar = SnackBar(content: Text('No Internet Connection'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  onClose() {
    setState(() {
      loadint = 15.0;
      loadtxt = 'Loading...';
    });

    _read();
  }

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';

    if (mob == '') {
      Navigator.pushReplacementNamed(context, 'LoginScreen');
    } else {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    }
  }

  location() async {}

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Container(
          height: 30.0,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: loadint,
                    height: loadint,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      backgroundColor: Colors.orange,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    '$loadtxt',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(decoration: BoxDecoration(
          //color: primarycolor
            image: DecorationImage(image: AssetImage('assets/images/splash.jpg',),fit:BoxFit.cover,colorFilter: new ColorFilter.mode(Colors.deepOrange.withOpacity(0.05), BlendMode.dstATop),)
        ),
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 1000),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Smack",
                      style:
                          TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ".",
                      style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                  ],
                ),
                Text(
                  'The flavour of food',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
