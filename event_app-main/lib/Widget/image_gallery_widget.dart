import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../app/config/app_colors.dart';
import '../app/config/app_text_style.dart';
import '../utils/animations.dart';
import '../utils/haptic_utils.dart';

class ImageGalleryWidget extends StatefulWidget {
  final List<String> imageUrls;
  final String? title;
  final int initialIndex;

  const ImageGalleryWidget({
    Key? key,
    required this.imageUrls,
    this.title,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenGallery() {
    HapticUtils.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imageUrls: widget.imageUrls,
          initialIndex: _currentIndex,
          title: widget.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 8.w, color: Colors.grey),
              SizedBox(height: 1.h),
              Text(
                'No images available',
                style: TextStyles.regularwhite.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyles.homeheadingtext.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 2.h),
        ],
        Container(
          height: 20.h,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: _openFullScreenGallery,
                    child: AppAnimations.fadeIn(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.h),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.h),
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.signinoptioncolor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.blueColor,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.signinoptioncolor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 8.w,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyles.regularwhite.copyWith(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (widget.imageUrls.length > 1) ...[
                // Page indicators
                Positioned(
                  bottom: 1.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                        width: _currentIndex == index ? 3.w : 2.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.blueColor
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                      ),
                    ),
                  ),
                ),
                // Image counter
                Positioned(
                  top: 1.h,
                  right: 2.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: TextStyles.regularwhite.copyWith(fontSize: 10.sp),
                    ),
                  ),
                ),
                // Tap to expand hint
                Positioned(
                  bottom: 3.h,
                  right: 2.w,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 4.w,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? title;

  const FullScreenGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    this.title,
  }) : super(key: key);

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            HapticUtils.light();
            Navigator.of(context).pop();
          },
        ),
        title: widget.title != null
            ? Text(
                widget.title!,
                style: TextStyles.regularwhite.copyWith(fontSize: 16.sp),
              )
            : null,
        actions: [
          if (widget.imageUrls.length > 1)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Text(
                  '${_currentIndex + 1}/${widget.imageUrls.length}',
                  style: TextStyles.regularwhite.copyWith(fontSize: 14.sp),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.blueColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 20.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Failed to load image',
                            style: TextStyles.regularwhite.copyWith(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 5.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: _currentIndex == index ? 4.w : 2.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppColors.blueColor
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
