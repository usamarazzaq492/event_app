
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReviewTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40.h,
          width: double.infinity,
          child: ListView.builder(
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return
                Image.asset('assets/images/review.png',color: Colors.white,);


              }
          ),
        )
      ],
    );
  }
}
