import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:convert' as convert;

void bottomsheetitem(context, veg, imglink, name, rate, hotelname, address,
    open, close, rating, norating, descr, id, uid) {
  final qtyTxt = TextEditingController();
  qtyTxt.text = "1";
  double temprating = (int.parse(rating) / int.parse(norating));
  int avgrating = temprating.toInt();
  Color vegclr;
  if (veg == '1') {
    vegclr = Colors.green;
  } else {
    vegclr = Colors.brown;
  }
  int qty = 1;
  String avltxt;
  Color avlclr;
  addcart() async {
    var newid = id;
    var newuid = uid;
    var url = Uri.parse('$apiurl/addcart.php?fid=$newid&uid=$newuid&qty=$qty');
    var response = await http.get(url);
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
    }
  }

  showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SingleChildScrollView(
          child: new Container(
            height: 470.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Container(
                              height: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Icon(
                                          Icons.brightness_1_rounded,
                                          color: vegclr,
                                          size: 15.0,
                                        ),
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      //Text('Non Veg',style: TextStyle(color: Colors.white),)
                                    ],
                                  ),
                                  Text(
                                    '$name',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹ $rate',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
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
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "HotelScreen",
                                  arguments: {"id": id});
                            },
                            child: Row(
                              children: [
                                Text(
                                  '$hotelname',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  Icons.link,
                                  color: Colors.grey.shade400,
                                )
                              ],
                            ),
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
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('$descr'),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          //Text('$avgrating/5 ($norating reviews)'),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 200,
                            child: NumberInputPrefabbed.roundedButtons(
                              onSubmitted: (value) {
                                qty = value;
                              },
                              onDecrement: (value) {
                                qty = value;
                              },
                              onIncrement: (value) {
                                qty = value;
                              },
                              controller: TextEditingController(),
                              min: 1,
                              scaleHeight: 0.7,
                              scaleWidth: 0.75,
                              initialValue: 1,
                              buttonArrangement:
                                  ButtonArrangement.incRightDecLeft,
                              isInt: true,
                              separateIcons: true,
                            ),
                          ),
                          Row(
                            children: [
                              // Flexible(
                              //   child: MaterialButton(
                              //     shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.all(
                              //             Radius.circular(10.0))),
                              //     elevation: 5.0,
                              //     color: Colors.deepOrange,
                              //     minWidth: double.infinity,
                              //     height: 45,
                              //     onPressed: () {},
                              //     child: Text(
                              //       'Add to Wishlist',
                              //       textAlign: TextAlign.center,
                              //       style: TextStyle(
                              //           color: Colors.white, fontSize: 15.0),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 15,
                              // ),
                              Flexible(
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  elevation: 5.0,
                                  color: Colors.deepOrange,
                                  minWidth: double.infinity,
                                  height: 45,
                                  onPressed: () {
                                    addcart();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Add to Cart',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        );
      });
}
