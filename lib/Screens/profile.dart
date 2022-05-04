import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:smack/Utilities/consta.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = "ProfileScreen";

  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '', mob, email, uid;

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mob = prefs.getString('mob') ?? '';
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      uid = prefs.getString('uid') ?? '';
    });
    connectaddress();
  }
  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('mob', '');
    Navigator.pushReplacementNamed(context, 'LoginScreen');
  }

  String addname = '', address1 = '', address2 = '', addmob = '';

  Future connectaddress() async {
    setState(() {});
    var urldata = '$apiurl/address.php?uid=$uid';
    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      if (status == 'Success') {
        setState(() {
          addname = result[0]['name'];
          address1 = "${result[0]['house']}";
          address2 = "${result[0]['landmark']}";
          addmob = result[0]['contact'];
        });
      } else {
        setState(() {});
      }
    }
  }

  String pwd='', pwd1;

  changepassword() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.all(10),
            height: 250,
            child: Column(
              children: [
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    pwd = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                  obscureText: true,
                  onChanged: (value) {
                    pwd1 = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  color: primarycolor,
                  minWidth: double.infinity,
                  height: 50,
                  onPressed: () async {
                    if( pwd!=''){
                      if (pwd == pwd1) {
                        var url = Uri.parse('$apiurl/passwordchange.php');
                        var response = await http.post(url, body: {'no': '$uid', 'password': '$pwd'});
                        // var urldata =
                        //     '$apiurl/passwordchange.php?no=$uid&password=$pwd';
                        // print(urldata);
                        // // Await the http get response, then decode the json-formatted response.
                        // var response = await http.get(Uri.parse(urldata));
                        if (response.statusCode == 200) {
                          print(response.body);
                          Navigator.pop(context);
                          showTopSnackBar(
                            context,
                            CustomSnackBar.info(
                              message: "${response.body}",
                            ),
                          );
                          pwd='';
                        }
                      }else
                        {
                          showTopSnackBar(
                            context,
                            CustomSnackBar.info(
                              message: "Passwords are not same.",
                            ),
                          );
                        }
                    }else{
                      showTopSnackBar(
                        context,
                        CustomSnackBar.info(
                          message: "Invaid password",
                        ),
                      );
                    }

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Update',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  initState() {
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primarycolor),
        title: Text(
          'Profile',
          style: TextStyle(color: primarycolor),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                          radius: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('${name.toUpperCase()}',
                            style: TextStyle(fontSize: 20)),
                        SizedBox(
                          height: 10,
                        ),
                        Text('$mob', style: TextStyle(fontSize: 15)),
                        SizedBox(
                          height: 2,
                        ),
                        Text('$email', style: TextStyle(fontSize: 15)),
                        SizedBox(
                          height: 2,
                        ),
                        Text('$address1', style: TextStyle(fontSize: 15)),
                        SizedBox(
                          height: 2,
                        ),
                        Text('$address2',
                            style: TextStyle(
                              fontSize: 15,
                            )),
                        SizedBox(
                          height: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'AddressScreen');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Change Address',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  changepassword();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Reset Password',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(
                            Icons.notifications,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Promotion Notification',
                              style: TextStyle(fontSize: 15)),
                        ]),
                        Switch(
                          value: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launch("$apiurl/joinus.html");
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_link,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Join Us',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Smack'),
              Text('Version 1.0.2')
            ],
          ),
        ),
      ),
    );
  }
}
