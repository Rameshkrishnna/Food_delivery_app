import 'package:flutter/material.dart';
import 'package:location/location.dart' as loca;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:smack/Utilities/singleItemListSmall.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SearchScreen extends StatefulWidget {
  static const String id = "SearchScreen";

  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Widget appBarTitle = new Text("Search",style: TextStyle(color: primarycolor),);
  Icon actionIcon = new Icon(Icons.search);
  String catno = '';
  List items = [];
  String sitem;
  String locationdt;
  String loadtxt = 'Searching...';

  _location() async {
    loca.Location location = new loca.Location();

    bool _serviceEnabled;
    loca.PermissionStatus _permissionGranted;
    loca.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loca.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loca.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print('$_locationData');
    locationdt = 'lat=${_locationData.latitude}&lon=${_locationData.longitude}';
    _read();
  }


  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    catno = prefs.getString('search') ?? '';
    connectitem(null);
  }

  Future connectitem(search) async {
    setState(() {
      sitem = '';
      items = [];
      loadtxt = 'Searching...';
    });
    var urldata;
    if (search == null) {
      urldata = '$apiurl/item.php?$locationdt&catno=$catno&item=';
    } else {
      urldata = '$apiurl/item.php?$locationdt&item=$search';
    }

    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      sitem = '$status';
      if (status == 'success') {
        setState(() {
          items = result;
          loadtxt = 'No items';
        });
      } else {
        loadtxt = '$result';
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "$result",
          ),
        );
        setState(() {
          items = [];
          loadtxt = '$result';
          sitem = '';
        });
      }
    }
  }

  String name, email, mob, uid;

  _readuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uid = prefs.getString('uid') ?? '';
  }

  initState() {
    _location();
    _readuser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.shopping_cart,color: primarycolor,),
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, 'CartScreen');
        },
      ),
      appBar: AppBar(backgroundColor: Colors.white,iconTheme: IconThemeData(color: primarycolor),titleTextStyle: TextStyle(color: primarycolor),
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(Icons.close);
                  this.appBarTitle = new TextField(textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      connectitem(value);
                    },
                    style: new TextStyle(color: primarycolor, fontSize: 20),
                    decoration: new InputDecoration(
                      //prefixIcon: new Icon(Icons.search,color: Colors.white),
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: primarycolor)),
                  );
                } else {
                  this.actionIcon = new Icon(Icons.search);
                  this.appBarTitle = new Text("Search",style: TextStyle(color: primarycolor),);
                }
              });
            },
          ),
        ],
      ),
      body: items.isEmpty==false
          ? SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: items.map((list) {
              return itemWdget(
                name: list['name'],
                id: list['id'],
                imglink: list['imglink'],
                hotelname: list['hotelname'],
                rating: list['rating'],
                norating: list['norating'],
                rate: list['rate'],
                veg: list['veg'],
                address: list['address'],
                close: list['close'],
                open: list['open'],
                descr: list['descr'],
                uid: uid,
              );
            }).toList(),
          ))
              : Container(
          width: MediaQuery.of(context).size.width,
      height: MediaQuery
          .of(context)
          .size
          .height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/burger.png',
            height: 100,
            width: 100,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            '$loadtxt',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    ),
    );
  }
}
