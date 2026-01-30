import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget TicketCard({
  required String title,
  required String date,
  required String location,
  String? imagePath,
  String? imageUrl,
  required String status,
  bool completed = false,
}) {
  return Container(
    margin:  EdgeInsets.only(bottom: 2.h),
    padding: EdgeInsets.only(left: 3.w,right: 3.w,bottom: 1.h),
    decoration: BoxDecoration(
      color: AppColors.signinoptioncolor,
      borderRadius: BorderRadius.circular(3.h),
    ),
    child: Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.circular(2.h),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 13.h,
                      height: 13.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 13.h,
                        height: 13.h,
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.blueColor),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 13.h,
                        height: 13.h,
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image, color: Colors.white70),
                      ),
                    )
                  : imagePath != null
                      ? Image.asset(imagePath, width: 13.h, height: 13.h, fit: BoxFit.cover)
                      : Container(
                          width: 13.h,
                          height: 13.h,
                          color: Colors.grey[800],
                          child: const Icon(Icons.event, color: Colors.white70),
                        ),
            ),
             SizedBox(width: 3.w),
            Expanded(
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style:  TextStyle(color: AppColors.whiteColor, fontSize: 15, fontWeight: FontWeight.bold)),
                     SizedBox(height: 1.h),
                    Text(date, style: const TextStyle(color: AppColors.blueColor, fontSize: 13)),
                     SizedBox(height: 1.h),
                    Row(
                      children: [
                        const Icon(Icons.location_pin, color: AppColors.blueColor, size: 16),
                         SizedBox(width: 3.w),
                        Text(location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1.h),
                            border: Border.all(color: completed ? Colors.green : Colors.red,)
                          ),
                          child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                  ],
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            if (completed) ...[
            Divider(color: Colors.grey, thickness: 0.5)        ,

            Row(
              children: [


                  Container(height: 5.h,
                  width: 40.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blueColor),
                      borderRadius: BorderRadius.circular(4.h)


                    ),
                    child: Center(child: Text("Leave a Review",style: TextStyles.homedatetext,)),
                  ),
                   SizedBox(width: 2.w),
                  Container(height: 5.h,
                    width: 40.w,
                    decoration: BoxDecoration(
              color:AppColors.blueColor,
                        borderRadius: BorderRadius.circular(4.h)


                    ),
                    child: Center(child: Text("View E-Ticket",style: TextStyles.ticketwhitetext,)),
                  ),

              ],
            ),
]
          ],
        )

      ],
    ),
  );
}
