import 'package:flutter/material.dart';

import 'itemSinglePopup.dart';

class itemWdget extends StatelessWidget {
  const itemWdget(
      {Key key,
      this.veg,
      this.imglink,
      this.name,
      this.rate,
      this.hotelname,
      this.address,
      this.open,
      this.close,
      this.rating,
      this.norating,
      this.descr,
      this.id,
      this.uid})
      : super(key: key);
  final veg,
      imglink,
      name,
      rate,
      hotelname,
      address,
      open,
      close,
      rating,
      norating,
      descr,
      id,
      uid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bottomsheetitem(context, veg, imglink, name, rate, hotelname, address,
            open, close, rating, norating, descr, id, uid);
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
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '₹ $rate',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.green,
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
                          '$hotelname',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
