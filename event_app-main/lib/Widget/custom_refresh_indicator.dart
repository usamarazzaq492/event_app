import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../app/config/app_colors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final String? message;

  const CustomRefreshIndicator({
    Key? key,
    required this.onRefresh,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.blueColor,
      backgroundColor: AppColors.signinoptioncolor,
      strokeWidth: 3.0,
      displacement: 60.0,
      child: child,
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const CustomLoadingIndicator({
    Key? key,
    this.message,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 8.w,
            height: size ?? 8.w,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.blueColor,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 2.h),
            Text(
              message!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class CustomShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const CustomShimmerEffect({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomShimmerEffect> createState() => _CustomShimmerEffectState();
}

class _CustomShimmerEffectState extends State<CustomShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.enabled) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
