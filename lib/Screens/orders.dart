import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smack/Utilities/consta.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:convert' as convert;

import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersScreen extends StatefulWidget {
  static const String id = "OrdersScreen";

  const OrdersScreen({Key key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List order = [];
  String name, email, mob, uid, loadtxt = '';

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mob = prefs.getString('mob') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uid = prefs.getString('uid') ?? '';
    connectorder();
  }

  Future connectorder() async {
    setState(() {
      loadtxt = 'Loading...';
    });
    var urldata = '$apiurl/getorder.php?uid=$uid';
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
          order = result;
        });
      } else {
        setState(() {
          loadtxt = 'No orders available';
        });
      }
    }
  }

  initState() {
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primarycolor),
        title: Text(
          'My Orders',
          style: TextStyle(color: primarycolor),
        ),
      ),
      body: order.isEmpty == false
          ? SingleChildScrollView(
              padding: EdgeInsets.all(5),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      children: order.map((list) {
                    return orderWidget(
                      hname: list['name'],
                      no: list['id'],
                      dt: list['dttime'],
                      rate: list['rate'],
                      otp: list['otp'],
                      statusno: list['status'],
                      cstatus: list['currentstatus'],
                      dcharge: list['dcharge'],
                      gst: list['gst'],
                      totamt: list['totamt'],
                      dname: list['dname'],
                      hmob: list['hmob'],
                      dmob: list['dmob'],
                    );
                  }).toList()),
                ],
              ))
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
    );
  }
}

class orderWidget extends StatelessWidget {
  const orderWidget(
      {Key key,
      this.hname,
      this.totamt,
      this.no,
      this.dt,
      this.statusno,
      this.otp,
      this.cstatus,
      this.gst,
      this.dcharge,
      this.rate,
      this.dname,
      this.hmob,
      this.dmob})
      : super(key: key);
  final hname,
      rate,
      no,
      dt,
      statusno,
      otp,
      cstatus,
      dcharge,
      gst,
      totamt,
      dname,
      hmob,
      dmob;

  @override
  Widget build(BuildContext context) {
    String statusnotxt;
    if (statusno == '0') {
      statusnotxt = "";
    } else {
      statusnotxt = "\n*Delivery OTP : $otp\n";
    }
    return GestureDetector(
      onTap: () {
        showTopSnackBar(
          context,
          CustomSnackBar.info(
            message: "Please wait...",
          ),
        );
        orderdetail(context, hname, rate, no, dt, statusno, otp, cstatus,
            dcharge, gst, totamt, dmob, hmob);
      },
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ORDER NO #$no $statusnotxt',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5,
                ),
                Text('Cooked By : $hname', style: TextStyle(fontSize: 15)),
                SizedBox(
                  height: 5,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date & Time  : $dt',
                          style: TextStyle(fontSize: 13)),
                      Text('₹ $totamt', style: TextStyle(fontSize: 15))
                    ]),
                SizedBox(
                  height: 5,
                ),
                Text('Status : $cstatus', style: TextStyle(fontSize: 12)),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

orderdetail(context, hname, rate, no, dt, statusno, otp, cstatus, dcharge, gst,
    totamt, dmob, hmob) async {
  var f = NumberFormat.currency(locale: 'HI', symbol: '₹');
  List items = [];
  var urldata = '$apiurl/getitem.php?no=$no';
  print(urldata);
  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(Uri.parse(urldata));
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    var result = jsonResponse['result'];
    print('$jsonResponse');
    items = result;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 500,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'ORDER NO #$no',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Cooked By : $hname'),
                  Text('Date & Time : $dt'),
                  Text('Status :$cstatus'),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Item',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Qty',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Amt',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Tot Amt',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      ],
                      rows: items.map((list) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text('${list['name']}')),
                            DataCell(Text('${list['qty']}')),
                            DataCell(Text('${list['rate']}')),
                            DataCell(Text((
                              double.parse(list['rate']) *
                                  double.parse(list['qty'])
                            ).toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rate'),
                              Text((f.format(double.parse('$rate'))).toString())
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('GST'),
                              Text((f.format(double.parse('$gst'))).toString())
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Charge'),
                              Text((f.format(double.parse('$dcharge')))
                                  .toString())
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  (f.format(double.parse('$totamt')))
                                      .toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                      ],
                    ),
                  ),
                  Container(
                    child: statusno != '0'
                        ? Row(
                            children: [
                              Flexible(
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  elevation: 5.0,
                                  color: primarycolor,
                                  minWidth: double.infinity,
                                  height: 50,
                                  onPressed: () {
                                    launch("tel:$hmob");
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        'Hotel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  elevation: 5.0,
                                  color: primarycolor,
                                  minWidth: double.infinity,
                                  height: 50,
                                  onPressed: () {
                                    if(dmob==''){
                                      showTopSnackBar(
                                        context,
                                        CustomSnackBar.info(
                                          message: "Delivery Boy not assigned",
                                        ),
                                      );
                                    }else{launch("tel:$dmob");}


                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        'Delivery Boy',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 5,
                          ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
