import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smack/Utilities/consta.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = "RegisterScreen";

  const RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String name = '', mob = '', email = '';

  void registration() async {
    if (name != '' && mob != '') {
      var url = Uri.parse('$apiurl/register.php');
      var response = await http
          .post(url, body: {'mob': '$mob', 'name': '$name', 'email': '$email'});
      print('Response body: ${response.body}');
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          message: "${response.body}",
        ),
      );
    } else {
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          message: "Some fields are missing.",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
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
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) {
                    name = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Name *',
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
                  maxLength: 10,
                  onChanged: (value) {
                    mob = value;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number *',
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
                    email = value;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  color: Colors.deepOrange,
                  minWidth: double.infinity,
                  height: 50,
                  onPressed: () {
                    registration();
                  },
                  child: Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      "By continuing you are indication that you accept our",
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    )),
                Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        launch("$apiurl/termsandpolicy.html");
                      },
                      child: Text(
                        'Terms and Privacy policy.',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 12,color: primarycolor
                        ),
                      ),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '-or-',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  elevation: 5.0,
                  color: Colors.deepOrange,
                  minWidth: double.infinity,
                  height: 50,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'LoginScreen');
                  },
                  child: Text(
                    'Existing User',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
