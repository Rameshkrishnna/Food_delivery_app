import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  static const String id = "NotificationScreen";

  const NotificationScreen({Key key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            notificationWidget(),
            notificationWidget(),
            notificationWidget()
          ],
        ),
      ),
    );
  }
}

class notificationWidget extends StatelessWidget {
  const notificationWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Heading',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
              SizedBox(height: 5,),
              Text('Content',style: TextStyle(fontSize: 15))
            ],
          ),
        ),
      ),
    );
  }
}
