import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:smack/Utilities/singleItemListSmall.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class HotelScreen extends StatefulWidget {
  static const String id = "HotelScreen";

  const HotelScreen({Key key}) : super(key: key);

  @override
  _HotelScreenState createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  List items = [];
  String id;

  String name, email, mob, uid;

  _readuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uid = prefs.getString('uid') ?? '';
  }

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('hotel') ?? '';
    connectitems();
  }

  String avltxt = 'Loading...';
  Color avlclr;

  String hname = 'Loading...',
      address = 'Loading...',
      open = '',
      close = '',
      hmob = '',
      imglink = '';

  Future connectitems() async {
    setState(() {});
    var urldata = '$apiurl/hotelsingle.php?id=$id';
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
          hname = result[0]['name'];
          address = result[0]['address'];
          open = result[0]['open'];
          close = result[0]['close'];
          mob = result[0]['mobile'];
          imglink = result[0]['imglink'];

          var available = result[0]['available'];
          if (available == '1') {
            avlclr = Colors.green;
            avltxt = 'Open';

            items = jsonResponse['item'];
          } else {
            avlclr = Colors.red;
            avltxt = 'Closed';

            items = [];
          }
        });
      } else {
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: "$result",
          ),
        );
        setState(() {
          items = [];
        });
      }
    }
  }

  initState() {
    _read();
    _readuser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: primarycolor),
          title: Text(
            'Restaurant',
            style: TextStyle(color: primarycolor),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.call,
                  //color: Colors.deepOrange,
                ),
                onPressed: () {
                  launch("tel:$mob");
                }),
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  //color: Colors.deepOrange,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'CartScreen');
                }),
          ]),
      body: Container(
        child: Column(
          children: [
            Stack(
              children: [
                FadeInImage(
                  image: NetworkImage('$imglink'),
                  placeholder: AssetImage('assets/images/imgplace.jpg'),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                ),
                Container(
                  height: 200,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        //const Color(0xCC000000),
                        //const Color(0x00000000),
                        const Color(0x00000000),
                        const Color(0xCC000000),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '$hname',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$avltxt',
                    style: TextStyle(
                        fontSize: 15,
                        color: avlclr,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.apartment,
                        size: 15,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '$address',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 15,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '$open to $close',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              height: MediaQuery.of(context).size.height - 370,
              child: SingleChildScrollView(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
