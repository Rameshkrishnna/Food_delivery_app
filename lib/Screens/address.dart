import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loca;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:convert' as convert;

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddressScreen extends StatefulWidget {
  static const String id = "AddressScreen";

  const AddressScreen({Key key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  loca.LocationData _currentPosition;
  Placemark _currentAddress;

  var conname = TextEditingController();
  var conpin = TextEditingController();
  var conhouse = TextEditingController();
  var conroad = TextEditingController();
  var concity = TextEditingController();
  var constate = TextEditingController();
  var conmob = TextEditingController();
  var conlandmark = TextEditingController();

  String aname = '',
      pin = '',
      house = '',
      road = '',
      city = '',
      state = '',
      amob = '',
      landmark = '';
  String name, email, mob, uid;

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uid = prefs.getString('uid') ?? '';
    connectaddress();
  }

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
          conname.text=result[0]['name'];
          conpin.text=result[0]['pincode'];
          conhouse.text=result[0]['house'];
          conroad.text=result[0]['road'];
          concity.text=result[0]['city'];
          constate.text=result[0]['state'];
          conlandmark.text=result[0]['landmark'];
          conmob.text=result[0]['contact'];
        });
      } else {
        setState(() {});
      }
    }
  }

  saveAddress() async {
    aname = conname.text;
    pin = conpin.text;
    house = conhouse.text;
    road = conroad.text;
    city = concity.text;
    state = constate.text;
    amob = conmob.text;
    landmark = conlandmark.text;

    if (aname == '' ||
        pin == '' ||
        house == '' ||
        road == '' ||
        city == '' ||
        state == '' ||
        amob == '') {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "Some fields are missing.",
        ),
      );
    } else {
      setState(() {});
      //`name`, `uid`, `pincode`, `house`, `road`, `city`, `state`, `contact`, `landmark`
      var urldata =
          '$apiurl/addresssave.php?uid=$uid&name=$aname&pincode=$pin&house=$house&road=$road&city=$city&state=$state&contact=$amob&landmark=$landmark';
      print('$urldata');
      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(Uri.parse(urldata));
      if (response.statusCode == 200) {
        print(response.body);
        showTopSnackBar(
          context,
          CustomSnackBar.success(
            message: response.body,
          ),
        );
      }
    }
  }

  initState() {
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,iconTheme: IconThemeData(color: primarycolor),
          title: Text("Your Address",style: TextStyle(color: primarycolor),),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    _location();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.gps_fixed),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Choose your current location')
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: conname,
                  onChanged: (value) {
                    name = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Name*',
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
                  controller: conpin,
                  onChanged: (value) {
                    pin = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Pincode*',
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
                  controller: conhouse,
                  onChanged: (value) {
                    house = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'House/Flat/Office Name*',
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
                  maxLines: 2,
                  controller: conroad,
                  onChanged: (value) {
                    road = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Road name,Area,Colony*',
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
                  controller: concity,
                  onChanged: (value) {
                    city = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'City*',
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
                  controller: constate,
                  onChanged: (value) {
                    state = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'State*',
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
                  controller: conmob,
                  onChanged: (value) {
                    amob = value;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact Number*',
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
                  controller: conlandmark,
                  onChanged: (value) {
                    landmark = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Landmark(optional)',
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
                  onPressed: () {
                    saveAddress();
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
                //Text("$_currentAddress")
              ],
            ),
          ),
        ));
  }

  _location() async {
    print('aaa');
    loca.Location localocation = new loca.Location();

    bool _serviceEnabled;
    loca.PermissionStatus _permissionGranted;
    loca.LocationData _locationData;

    _serviceEnabled = await localocation.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await localocation.requestService();
      if (!_serviceEnabled) {
        _location();
      }
    }

    _permissionGranted = await localocation.hasPermission();
    if (_permissionGranted == loca.PermissionStatus.denied) {
      _permissionGranted = await localocation.requestPermission();
      if (_permissionGranted != loca.PermissionStatus.granted) {
        _location();
      }
    }
    loca.Location.instance
        .changeSettings(accuracy: loca.LocationAccuracy.navigation);

    _locationData = await loca.Location.instance.getLocation();
    print('$_locationData');
    _currentPosition = _locationData;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude, _locationData.longitude);

    Placemark place = placemarks[0];
    print('$place');
    _getAddressFromLatLng();
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = place;
        conpin.text = '${_currentAddress.postalCode}';
        constate.text = '${_currentAddress.administrativeArea}';
        concity.text = '${_currentAddress.subAdministrativeArea}';
        conlandmark.text = '${_currentAddress.street}';
        conroad.text =
            '${_currentAddress.name}, ${_currentAddress.locality}, ${_currentAddress.administrativeArea}, ${_currentAddress.postalCode}, ${_currentAddress.country}';
      });
    } catch (e) {
      print(e);
    }
  }
}
