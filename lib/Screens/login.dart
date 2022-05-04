import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "LoginScreen";

  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double indsize = 0.0;
  String password, mob, token, id;
  String name, email, change_pwd_mob;

  connection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none) {
      final snackBar = SnackBar(content: Text('No Internet Connection'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  forgotpwd() {
    change_pwd_mob='';
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: 150.0,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    change_pwd_mob = value;
                  },keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile number',
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  color: Colors.deepOrange,
                  minWidth: double.infinity,
                  height: 50,
                  onPressed: () {
                    if (change_pwd_mob != '') {
                      print(change_pwd_mob);
                      setpassword();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ],
            ),
          );
        });
  }

  setpassword() async {
    var url = Uri.parse('$apiurl/setpassword.php');
    var response =
        await http.post(url, body: {'mob': '$change_pwd_mob'});
    print('Response body: ${response.body}');
    showTopSnackBar(
      context,
      CustomSnackBar.info(
        message: "${response.body}",
      ),
    );
  }

  checkLogin(mob, password) async {
    setState(() {
      indsize = 15.0;
    });
    var url = Uri.parse('$apiurl/login.php');
    var response =
        await http.post(url, body: {'mobile': '$mob', 'password': '$password'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var status = jsonResponse['status'];
      var result = jsonResponse['result'];

      if (status == 'success') {
        var jsonResult = result;
        token = jsonResult['token'];
        print(token);
        mob = jsonResult['mobile'];
        name = jsonResult['name'];
        email = jsonResult['email'];
        id = jsonResult['id'];
        var newtoken = await FirebaseMessaging.instance.getToken();
        if (token == newtoken) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', newtoken);
          prefs.setString('mob', mob);
          prefs.setString('name', name);
          prefs.setString('email', email);
          prefs.setString('uid', id);
          Navigator.pushReplacementNamed(context, 'HomeScreen');
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', newtoken);
          prefs.setString('mob', mob);
          prefs.setString('name', name);
          prefs.setString('email', email);
          prefs.setString('uid', id);
          var url =
              Uri.parse('$apiurl/tokenchange.php?token=$newtoken&mob=$mob');
          var response = await http.get(url);
          print('$url');
          Navigator.pushReplacementNamed(context, 'HomeScreen');
        }
      } else {
        setState(() {
          indsize = 0.0;
        });

        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "$result",
          ),
        );
      }
    }
  }

  void initState() {
    super.initState();
    connection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                child: Image.asset(
                  'assets/images/pizza.png',
                  width: 200,
                ),
                alignment: Alignment.topRight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Smack",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
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
              SizedBox(
                height: 50,
              ),
              TextFormField(
                maxLength: 10,
                onChanged: (value) {
                  mob = value;
                },
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: new BorderSide(),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: new BorderSide(),
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              GestureDetector(
                onTap: () {
                  forgotpwd();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    child: Text('Forgot Password',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.deepOrange,
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                elevation: 5.0,
                color: Colors.deepOrange,
                minWidth: double.infinity,
                height: 50,
                onPressed: () {
                  checkLogin(mob, password);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: indsize,
                      height: indsize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        backgroundColor: Colors.cyanAccent,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: indsize,
                    ),
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '-or-',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                elevation: 5.0,
                color: Colors.deepOrange,
                minWidth: double.infinity,
                height: 50,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'RegisterScreen');
                },
                child: Text(
                  'New User',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
