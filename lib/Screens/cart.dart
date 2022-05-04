import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:convert' as convert;

import 'package:flutter/services.dart';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CartScreen extends StatefulWidget {
  static const String id = "CartScreen";

  const CartScreen({Key key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cart = [];
  String loadtxt = 'Loading...';
  String name, email, mob, uid;
  String totrate, totgst, dcharge, grandtotal, dnote;

  var f = NumberFormat.currency(locale: 'HI', symbol: '₹');

  Future order() async {
    setState(() {
      loadtxt = 'Loading...';
      cart = [];
    });
    var url = Uri.parse('$apiurl/order.php');
    var response = await http.post(url, body: {'uid': '$uid', 'dnote': '$dnote'});
    // var urldata = '$apiurl/order.php?uid=$uid&note=$dnote';
    // print(urldata);
    // Await the http get response, then decode the json-formatted response.
    // var response = await http.get(Uri.parse(urldata));
    print (response.body);
    if (response.statusCode == 200) {
      if (response.body == '1') {
        showTopSnackBar(
          context,
          CustomSnackBar.success(
            message: "Order Placed",
          ),
        );
        connectcart();
      }else{
        showTopSnackBar(
          context,
          CustomSnackBar.error(
            message: response.body,
          ),
        );
        connectcart();
      }
    }
  }

  String addname, address1, address2, addmob;

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
        addname = result[0]['name'];
        if (addname == '') {
          showTopSnackBar(
            context,
            CustomSnackBar.info(
              message: "Please update your address",
            ),
          );
          Navigator.pushNamed(context, 'AddressScreen');
        }
        setState(() {
          addname = result[0]['name'];
          address1 = "${result[0]['house']} ,${result[0]['landmark']}";
          address2 = "${result[0]['road']}";
          addmob = result[0]['contact'];
        });
      } else {
        setState(() {});
      }
    }
  }

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uid = prefs.getString('uid') ?? '';
    connectcart();
  }

  Future connectcart() async {
    setState(() {
      loadtxt = 'Loading...';
      cart = [];
    });
    connectaddress();
    var urldata = '$apiurl/cart.php?uid=$uid';
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
          cart = result;
          grandtotal = (f.format((jsonResponse['totmrp'])));
          totgst = (f.format(double.parse('${jsonResponse['totgst']}')));
          totrate = (f.format(double.parse('${jsonResponse['totrate']}')));
          dcharge = (f.format(double.parse('${jsonResponse['dcharge']}')));
        });
      } else {
        setState(() {
          loadtxt = 'Empty Cart';
          cart = [];
        });
      }
    }
  }

  Future clearcart() async {
    setState(() {
      loadtxt = 'Loading...';
      cart = [];
    });
    var urldata = '$apiurl/clearcart.php?uid=$uid';
    var response = await http.get(Uri.parse(urldata));
    if (response.statusCode == 200) {
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          icon: Icon(
            Icons.shopping_cart_rounded,
            size: 100,
            color: Colors.indigo,
          ),
          message: "${response.body}",
        ),
      );
      _read();
    }
  }

  @override
  initState() {
    super.initState();
    //_read();
  }

  @override
  Widget build(BuildContext context) => FocusDetector(
        onFocusGained: () {
          _read();
        },
        child: Scaffold(
          bottomNavigationBar: cart.isEmpty != true
              ? Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  //// Bottom Naviagtion Bar for check out and Total price
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: Text("Total"),
                          subtitle: Text("$grandtotal"),
                        ),
                      ),
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            order();
                          },
                          child: Text(
                            "Check Out",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: primarycolor,
                          height: 50,
                        ),
                      )
                    ],
                  ),
                )
              : Text(''),
          appBar: AppBar(backgroundColor: Colors.white,iconTheme: IconThemeData(color: primarycolor),
            title: Text('My Cart',style: TextStyle(color: primarycolor),),
          ),
          body: cart.isEmpty != true
              ? SingleChildScrollView(
                  padding: EdgeInsets.all(5),
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            clearcart();
                          },
                          child: Container(
                            width: 110,
                            child: Card(
                              color: Colors.grey.shade200,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_rounded,
                                      size: 15,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Clear Cart')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                      Column(
                        children: cart.map((list) {
                          return cartitemWidget(
                            name: list['name'],
                            imglink: list['imglink'],
                            amt: list['rate'],
                            qty: list['qty'],
                            id: list['id'],
                          );
                        }).toList(),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          maxLines: 2,
                          onChanged: (value) {
                            dnote = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'Delivery note',
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        height: 170,
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Delivery Details',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, 'AddressScreen');
                                        },
                                        child: Card(
                                          color: Colors.grey.shade200,
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  size: 15,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text('Change')
                                              ],
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('$addname'),
                                Text('$address1'),
                                Text('$address2'),
                                Text('Mob : $addmob'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.all(5),
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 150,
                      //   child: Card(
                      //     child: Container(
                      //       padding: EdgeInsets.all(10),
                      //       child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text('Payment Method',
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.bold, fontSize: 15)),
                      //           SizedBox(
                      //             height: 15,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Container(
                          padding: EdgeInsets.all(5),
                          height: 160,
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Item Total'),
                                      Text('$totrate'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('GST'),
                                      Text('$totgst'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Delivery Charge'),
                                      Text('$dcharge'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Grand Total (₹)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '$grandtotal',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )),
                      // MaterialButton(
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(10.0))),
                      //   elevation: 5.0,
                      //   color: primarycolor,
                      //   minWidth: double.infinity,
                      //   height: 50,
                      //   onPressed: () {
                      //     order();
                      //   },
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'Checkout',
                      //         textAlign: TextAlign.center,
                      //         style: TextStyle(
                      //             color: Colors.white, fontSize: 15.0),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
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
        ),
      );
}

class cartitemWidget extends StatelessWidget {
  const cartitemWidget(
      {Key key, this.name, this.id, this.amt, this.imglink, this.qty})
      : super(key: key);
  final name, id, amt, imglink, qty;

  @override
  Widget build(BuildContext context) {
    double totprice = double.parse(amt) * double.parse(qty);
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      singlecartdelete(id, context);
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FadeInImage(
                    image: NetworkImage('$imglink'),
                    placeholder: AssetImage('assets/images/imgplace.jpg'),
                    fit: BoxFit.cover,
                    width: 70,
                    height: 50,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
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
                      Row(
                        children: [
                          Text('₹ $amt X  '),
                          Container(
                            width: 110,
                            height: 30,
                            child: NumberInputPrefabbed.squaredButtons(
                              onIncrement: (value) {
                                qtychange(id, value, context);
                              },
                              onDecrement: (value) {
                                qtychange(id, value, context);
                              },
                              onSubmitted: (value) {
                                qtychange(id, value, context);
                              },
                              controller: TextEditingController(),
                              min: 1,
                              scaleHeight: 0.7,
                              scaleWidth: 0.75,
                              initialValue: int.parse(qty),
                              buttonArrangement: ButtonArrangement.incRightDecLeft,
                              incDecBgColor: Colors.white,
                              incIconSize: 30,
                              decIconSize: 30,
                              isInt: true,
                              separateIcons: true,
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$totprice',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

void singlecartdelete(id, context) async {
  showTopSnackBar(
    context,
    CustomSnackBar.info(
      message: "Please wait...",
    ),
  );
  var urldata = '$apiurl/singlecartdelete.php?id=$id';
  print(urldata);
  var response = await http.get(Uri.parse(urldata));
  Navigator.pushReplacementNamed(context, 'CartScreen');
}

void qtychange(id, qty, context) async {
  showTopSnackBar(
    context,
    CustomSnackBar.info(
      message: "Please Wait...",
    ),
  );
  var urldata = '$apiurl/changeqty.php?id=$id&qty=$qty';
  print(urldata);
  var response = await http.get(Uri.parse(urldata));
  Navigator.pushReplacementNamed(context, 'CartScreen');
}
