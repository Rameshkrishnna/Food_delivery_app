import 'package:carousel_slider/carousel_slider.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loca;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:smack/Utilities/itemSinglePopup.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  static const String id = "HomeScreen";

  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List listImages = [];
  List category = [];
  List popular = [];
  List hotel = [];
  List banner = [];
  String name = '', email, mob, uid;

  String ploading = 'Loading...', hloading = 'Loading...';

  //Position _currentPosition;
  loca.LocationData _currentPosition;
  Placemark _currentAddress;
  String placename = "Loading...";
  String linklocation;
  String shotel, spopular = 'fail';

  _location() async {
    print('aaa');
    loca.Location location = new loca.Location();

    bool _serviceEnabled;
    loca.PermissionStatus _permissionGranted;
    loca.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        _location();
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loca.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loca.PermissionStatus.granted) {
        _location();
      }
    }

    loca.Location.instance.changeSettings(accuracy: loca.LocationAccuracy.high);

    _locationData = await loca.Location.instance.getLocation();
    print('$_locationData');
    _currentPosition = _locationData;
    linklocation =
        "lat=${_locationData.latitude}&lon=${_locationData.longitude}";
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude, _locationData.longitude);

    Placemark place = placemarks[0];
    print('$place');
    _getAddressFromLatLng();
    connecthotel();
    connectpopular();

    var newtoken = await FirebaseMessaging.instance.getToken();

    var url = Uri.parse('$apiurl/tokenchange.php?token=$newtoken&mob=$mob');
    var response = await http.get(url);
  }

  // _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     await Geolocator.openLocationSettings();
  //   }
  //   Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.lowest,
  //           forceAndroidLocationManager: true)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //       linklocation = "lat=${position.latitude}&lon=${position.longitude}";
  //       connectpopular();
  //       connecthotel();
  //       connectbanner();
  //       print('$position');
  //       _getAddressFromLatLng();
  //     });
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = place;
        placename = _currentAddress.locality;
      });
      print('$place');
    } catch (e) {
      print(e);
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('mob', '');
    Navigator.pushReplacementNamed(context, 'LoginScreen');
  }

  passData(data, type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('$type', '$data');
  }

  Future connectcategory() async {
    setState(() {});
    var urldata = '$apiurl/category.php';
    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      setState(() {
        category = result;
      });
    }
  }

  Future connectbanner() async {
    setState(() {});
    var urldata = '$apiurl/banner.php';
    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      setState(() {
        banner = result;
      });
    }
  }

  Future connectslider() async {
    setState(() {});
    var urldata = '$apiurl/sliderimg.php';
    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      setState(() {
        listImages = result;
      });
    }
  }

  Future connectpopular() async {
    setState(() {});
    var urldata = '$apiurl/popular.php?$linklocation';
    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      setState(() {
        popular = result;
        spopular = status;
        ploading = 'No items available';
      });
    }
  }

  Future connecthotel() async {
    setState(() {});
    var urldata = '$apiurl/hotel.php?$linklocation';
    print(urldata);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var result = jsonResponse['result'];
      var status = jsonResponse['status'];
      print('$jsonResponse');
      setState(() {
        hotel = result;
        shotel = status;
        hloading = 'No hotels available';
      });
    }
  }

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uid = prefs.getString('uid') ?? '';
  }

  initState() {
    //_getCurrentLocation();
    _location();
    connectslider();
    connectcategory();
    _read();
  }

  _onItemTapped(int Index) {
    if (Index == 1) {
      Navigator.pushNamed(context, 'OrdersScreen');
    }
    if (Index == 2) {
      Navigator.pushNamed(context, 'ProfileScreen');
    }
    print(Index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        backgroundColor: primarycolor,
        onPressed: () {
          Navigator.pushNamed(context, 'CartScreen');
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        //currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: primarycolor),
        backgroundColor: Colors.white,
        elevation: 3,
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'AddressScreen');
          },
          child: Row(
            children: [
              Icon(
                Icons.location_on,
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Address',
                    style: TextStyle(fontSize: 8, color: primarycolor),
                  ),
                  Text(
                    '$placename',
                    style: TextStyle(fontSize: 15, color: primarycolor),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        //iconTheme: IconThemeData(color: primarycolor),
        actions: <Widget>[
          // IconButton(
          //     icon: Icon(
          //       Icons.notifications, color: primarycolor,
          //     ),
          //     onPressed: () {
          //       //Navigator.pushNamed(context, 'SearchScreen');
          //     }),
          IconButton(
              icon: Icon(
                Icons.search, color: primarycolor,
                //color: primarycolor,
              ),
              onPressed: () {
                passData(0, 'search');
                Navigator.pushNamed(context, 'SearchScreen');
              }),
          IconButton(
              icon: Icon(
                Icons.logout, color: primarycolor,
                //color: primarycolor,
              ),
              onPressed: () {
                logout();
              }),
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     // Important: Remove any padding from the ListView.
      //
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       UserAccountsDrawerHeader(
      //         accountName: Text(
      //           '${name.toUpperCase()}',
      //           style: TextStyle(
      //               color: Colors.grey.shade800, fontWeight: FontWeight.bold),
      //         ),
      //         accountEmail: Text('$mob',
      //             style: TextStyle(
      //                 color: Colors.grey.shade800,
      //                 fontWeight: FontWeight.bold)),
      //         // currentAccountPicture: CircleAvatar(
      //         //   child: Icon(
      //         //     Icons.person_rounded,
      //         //     size: 60.0,
      //         //     color: primarycolor,
      //         //   ),
      //         //   backgroundColor: Colors.white,
      //         // ),
      //         decoration: BoxDecoration(
      //             //color: primarycolor
      //             image: DecorationImage(
      //           image: AssetImage('assets/images/imgplace.jpg'),
      //           fit: BoxFit.cover,
      //           colorFilter: new ColorFilter.mode(
      //               Colors.deepOrange.withOpacity(0.1), BlendMode.dstATop),
      //         )),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.list),
      //         title: Text('Orders'),
      //         onTap: () {
      //           Navigator.pushNamed(context, 'OrdersScreen');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.shopping_cart),
      //         title: Text('Cart'),
      //         onTap: () {
      //           Navigator.pushNamed(context, 'CartScreen');
      //         },
      //       ),
      //       // ListTile(
      //       //   leading: Icon(Icons.star),
      //       //   title: Text('Wishlist'),
      //       //   onTap: () {
      //       //     //Navigator.pushReplacementNamed(context, LoginScreen.id);
      //       //   },
      //       // ),
      //       // ListTile(
      //       //   leading: Icon(Icons.notifications),
      //       //   title: Text('Notification'),
      //       //   onTap: () {
      //       //     Navigator.pushNamed(context, 'NotificationScreen');
      //       //   },
      //       // ),
      //       ListTile(
      //         leading: Icon(Icons.person_rounded),
      //         title: Text('Profile'),
      //         onTap: () {
      //           Navigator.pushNamed(context, 'ProfileScreen');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.logout),
      //         title: Text('Logout'),
      //         onTap: () {
      //           logout();
      //         },
      //       ),
      //       // ListTile(
      //       //   leading: Icon(Icons.all_inclusive),
      //       //   title: Text('Join Us'),
      //       //   subtitle: Text('For ads & Promotions'),
      //       //   onTap: () {
      //       //     //Navigator.pushReplacementNamed(context, LoginScreen.id);
      //       //   },
      //       // ),
      //       // ListTile(
      //       //   leading: Icon(Icons.bug_report),
      //       //   title: Text('Report Bug'),
      //       //   onTap: () {
      //       //     //Navigator.pushReplacementNamed(context, LoginScreen.id);
      //       //   },
      //       // ),
      //       // ListTile(
      //       //   leading: Icon(Icons.app_settings_alt),
      //       //   title: Text('About'),
      //       //   subtitle: Text('Version : 1.0.0'),
      //       //   onTap: () {
      //       //     //Navigator.pushReplacementNamed(context, LoginScreen.id);
      //       //   },
      //       // ),
      //       // Image.network(
      //       //   '',
      //       //   fit: BoxFit.cover,
      //       //   width: MediaQuery.of(context).size.width,
      //       // ),
      //     ],
      //   ),
      // ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          //padding: EdgeInsets.all(5),
          child: Column(
            children: [
              // SizedBox(
              //   height: 10,
              // ),

              SizedBox(
                height: 5,
              ),

              SizedBox(
                height: 5,
              ),
              CarouselSlider(
                options: CarouselOptions(
                  //enlargeCenterPage: true,
                  height: 150.0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 10),
                ),
                items: listImages.map((list) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Card(
                        elevation: 1.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(5),
                            color: Colors.black12,
                          ),
                          child: FadeInImage(
                            image: NetworkImage(list['imglink']),
                            placeholder:
                                AssetImage('assets/images/imgplace.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: category.map((list) {
                    return catWidget(
                      catno: list['id'],
                      imglink: list['imglink'],
                      name: list['name'],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Today Special',
                    style: TextStyle(
                        fontSize: 15,
                        color: primarycolor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: popular.isEmpty == false
                      ? new Row(
                          children: popular.map((list) {
                            return popularWidget(
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
                        )
                      : Column(
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
                              '$ploading',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
              SizedBox(
                height: 10,
              ),
              // Image.network(
              //   '',
              //   fit: BoxFit.cover,
              //   width: MediaQuery.of(context).size.width,
              // ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Nearby You',
                    style: TextStyle(
                        fontSize: 15,
                        color: primarycolor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: hotel.isEmpty == false
                      ? new Column(
                          children: hotel.map((list) {
                            return hotelWidget(
                              id: list['id'],
                              open: list['open'],
                              close: list['close'],
                              name: list['name'],
                              address: list['address'],
                              imglink: list['imglink'],
                              available: list['available'],
                            );
                          }).toList(),
                        )
                      : Column(
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
                              '$hloading',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
              SizedBox(
                height: 10,
              ),
              // Image.network(
              //   '',
              //   fit: BoxFit.cover,
              //   width: MediaQuery.of(context).size.width,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class hotelWidget extends StatelessWidget {
  const hotelWidget(
      {Key key,
      this.name,
      this.available,
      this.address,
      this.open,
      this.close,
      this.imglink,
      this.id})
      : super(key: key);
  final name, address, available, open, close, imglink, id;

  @override
  Widget build(BuildContext context) {
    String avltxt;
    Color avlclr;
    if (available == '1') {
      avlclr = Colors.green;
      avltxt = 'Open';
    } else {
      avlclr = Colors.red;
      avltxt = 'Closed';
    }
    passData(data, type) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('$type', '$data');
    }

    return GestureDetector(
      onTap: () {
        passData(id, 'hotel');
        Navigator.pushNamed(context, "HotelScreen");
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(2),
          child: Row(
            children: [
              FadeInImage(
                image: NetworkImage('$imglink'),
                placeholder: AssetImage('assets/images/imgplace.jpg'),
                fit: BoxFit.cover,
                width: 110,
                height: 80,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name',
                      style: TextStyle(
                          fontSize: 15,
                          color: primarycolor,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '$avltxt',
                      style: TextStyle(
                          fontSize: 10,
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
                              fontSize: 12,
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
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class catWidget extends StatelessWidget {
  const catWidget({Key key, this.imglink, this.name, this.catno})
      : super(key: key);
  final imglink, name, catno;

  @override
  passData(data, type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('$type', '$data');
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        passData(catno, 'search');
        Navigator.pushNamed(context, "SearchScreen");
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(2),
          child: Column(
            children: [
              FadeInImage(
                image: NetworkImage('$imglink'),
                placeholder: AssetImage('assets/images/imgplace.jpg'),
                fit: BoxFit.cover,
                width: 110,
                height: 80,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$name',
                style: TextStyle(
                    fontSize: 15,
                    color: primarycolor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class popularWidget extends StatelessWidget {
  const popularWidget(
      {Key key,
      this.id,
      this.name,
      this.hotelname,
      this.rating,
      this.norating,
      this.imglink,
      this.rate,
      this.veg,
      this.address,
      this.open,
      this.close,
      this.descr,
      this.uid})
      : super(key: key);
  final id,
      name,
      hotelname,
      rating,
      norating,
      imglink,
      rate,
      veg,
      address,
      open,
      close,
      descr,
      uid;

  @override
  Widget build(BuildContext context) {
    double temprating = (int.parse(rating) / int.parse(norating));
    int avgrating = temprating.toInt();
    return GestureDetector(
      onTap: () {
        bottomsheetitem(context, veg, imglink, name, rate, hotelname, address,
            open, close, rating, norating, descr, id, uid);
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInImage(
                image: NetworkImage('$imglink'),
                placeholder: AssetImage('assets/images/imgplace.jpg'),
                fit: BoxFit.cover,
                width: 200,
                height: 110,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$name',
                style: TextStyle(
                    fontSize: 18,
                    color: primarycolor,
                    fontWeight: FontWeight.bold),
              ),
              Text('$hotelname'),
              //Text('$avgrating/5 ($norating reviews)'),
            ],
          ),
          height: 170,
          width: 200,
        ),
      ),
    );
  }
}
