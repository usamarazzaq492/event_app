import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../app/config/app_colors.dart';

class SkeletonLoading {
  static Widget eventCardSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 20.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.h),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 2.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0.5.h),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 1.5.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0.5.h),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 1.5.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0.5.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget profileCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: CircleAvatar(
              radius: 8.h,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 2.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 1.5.h,
              width: 60.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSkeletonColumn(),
              Container(height: 5.h, width: 1, color: Colors.grey.shade600),
              _buildSkeletonColumn(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildSkeletonColumn() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 2.h,
            width: 3.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 1.5.h,
            width: 8.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
        ),
      ],
    );
  }

  static Widget listSkeleton({int itemCount = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => eventCardSkeleton(),
    );
  }

  static Widget profileSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        children: [
          profileCardSkeleton(),
          SizedBox(height: 3.h),
          _buildTabSkeleton(),
          SizedBox(height: 2.h),
          _buildContentSkeleton(),
        ],
      ),
    );
  }

  static Widget _buildTabSkeleton() {
    return Container(
      height: 6.h,
      child: Row(
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContentSkeleton() {
    return Container(
      height: 30.h,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(2.h),
          decoration: BoxDecoration(
            color: AppColors.signinoptioncolor,
            borderRadius: BorderRadius.circular(2.h),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 2.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0.5.h),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 1.5.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0.5.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
