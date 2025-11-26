import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../app/config/app_colors.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imagePath;

  const EventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.location,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.only(left: 3.w, right: 3.w, bottom: 1.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(3.h),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2.h),
                child: Image.asset(imagePath, width: 13.h, height: 13.h, fit: BoxFit.cover),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: AppColors.whiteColor, fontSize: 13, fontWeight: FontWeight.bold)),
                      SizedBox(height: 1.h),
                      Text(date, style: const TextStyle(color: AppColors.blueColor, fontSize: 13)),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: AppColors.blueColor, size: 16),
                          SizedBox(width: 3.w),
                          Expanded( // To avoid overflow
                            child: Text(location, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
