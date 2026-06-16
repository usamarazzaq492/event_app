import 'dart:ui';
import 'package:event_app/MVVM/body_model/ticket_tier_model.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/View/paymentMethod/payment_method.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class BookEventScreen extends StatefulWidget {
  final int? id;

  const BookEventScreen({super.key, required this.id});

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen>
    with SingleTickerProviderStateMixin {
  final EventController _eventController = Get.find<EventController>();
  List<TicketTier> _localTiers = [];
  bool _loading = true;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadTiers();
  }

  Future<void> _loadTiers() async {
    if (widget.id == null) {
      setState(() => _loading = false);
      return;
    }
    await _eventController.fetchEventTiers(widget.id!);
    // Make local mutable copies (selectedQuantity starts at 0)
    setState(() {
      _localTiers = _eventController.tiers
          .map((t) => TicketTier(
                tierId:      t.tierId,
                tierName:    t.tierName,
                price:       t.price,
                quantityCap: t.quantityCap,
                quantitySold:t.quantitySold,
                available:   t.available,
                isSoldOut:   t.isSoldOut,
                description: t.description,
              ))
          .toList();
      _loading = false;
    });
  }

  // ── Computed ───────────────────────────────────────────────────────────────
  double get _total => _localTiers.fold(
      0.0, (sum, t) => sum + t.price * t.selectedQuantity);

  int get _totalCount =>
      _localTiers.fold(0, (sum, t) => sum + t.selectedQuantity);

  List<TicketTier> get _selectedTiers =>
      _localTiers.where((t) => t.selectedQuantity > 0).toList();

  String get _summaryText {
    if (_totalCount == 0) return 'Select at least one ticket';
    return _selectedTiers
        .map((t) => '${t.tierName} x${t.selectedQuantity}')
        .join('  •  ');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _adjustQty(int index, int delta) {
    final tier = _localTiers[index];
    if (tier.isSoldOut && delta > 0) return;

    final newQty = (tier.selectedQuantity + delta).clamp(
      0,
      tier.quantityCap != null
          ? (tier.available ?? tier.quantityCap!)
          : 99,
    );

    if (newQty == tier.selectedQuantity) return;
    HapticUtils.light();
    setState(() => _localTiers[index].selectedQuantity = newQty);
  }

  void _onContinue() {
    if (_totalCount == 0) return;
    HapticUtils.buttonPress();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          id:            widget.id,
          selectedTiers: _selectedTiers,
          totalAmount:   _total,
          // Combine all selected tiers into a single string for the payment webview
          category: _selectedTiers.map((t) => '${t.selectedQuantity}x ${t.tierName}').join(', '),
          seats:    _totalCount,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -15.h,
            left: -15.w,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -10.h,
            right: -10.w,
            child: Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
                _buildStickyBottom(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.navigation();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16.sp),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Book Tickets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.blueColor,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 2.h),
            Text('Loading ticket tiers…',
                style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
          ],
        ),
      );
    }

    if (_localTiers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.confirmation_num_outlined,
                  color: Colors.white24, size: 40.sp),
              SizedBox(height: 2.h),
              Text('No ticket types configured',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              Text('The organizer has not set up ticket tiers yet.\nPlease check back later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      children: [
        // Section heading
        Padding(
          padding: EdgeInsets.only(bottom: 2.h, left: 0.5.w),
          child: Row(
            children: [
              Text(
                'SELECT YOUR TICKETS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Tier cards
        ...List.generate(_localTiers.length, (i) => _buildTierCard(i)),

        SizedBox(height: 2.h),

        // Price info note
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Colors.white24, size: 12.sp),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Prices shown are per ticket, excluding processing fees.',
                  style:
                      TextStyle(color: Colors.white24, fontSize: 9.5.sp),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h), // space for sticky bottom
      ],
    );
  }

  // ── Tier Card ──────────────────────────────────────────────────────────────
  Widget _buildTierCard(int index) {
    final tier = _localTiers[index];
    final isFree = tier.price == 0;
    final qty = tier.selectedQuantity;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 1.8.h),
      decoration: BoxDecoration(
        color: qty > 0
            ? AppColors.blueColor.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(2.2.h),
        border: Border.all(
          color: tier.isSoldOut
              ? Colors.red.withValues(alpha: 0.25)
              : qty > 0
                  ? AppColors.blueColor.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.09),
          width: qty > 0 ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.2.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
            child: Row(
              children: [
                // Emoji icon
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: tier.isSoldOut
                        ? Colors.red.withValues(alpha: 0.1)
                        : AppColors.blueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1.2.h),
                  ),
                  child: Center(
                    child: Text(
                      tier.tierEmoji,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),

                SizedBox(width: 3.5.w),

                // Name + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.tierName,
                            style: TextStyle(
                              color: tier.isSoldOut
                                  ? Colors.white38
                                  : Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (tier.isSoldOut) ...[
                            SizedBox(width: 2.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.3.h),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(1.h),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'SOLD OUT',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 7.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (tier.description != null &&
                          tier.description!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 0.4.h),
                          child: Text(
                            tier.description!,
                            style: TextStyle(
                                color: Colors.white38, fontSize: 9.5.sp),
                          ),
                        ),
                      if (tier.quantityCap != null && !tier.isSoldOut)
                        Padding(
                          padding: EdgeInsets.only(top: 0.4.h),
                          child: Text(
                            '${tier.available} left',
                            style: TextStyle(
                              color: (tier.available ?? 999) < 10
                                  ? Colors.orangeAccent
                                  : Colors.white24,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isFree ? 'FREE' : '\$${tier.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isFree
                            ? Colors.greenAccent
                            : tier.isSoldOut
                                ? Colors.white24
                                : Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!isFree)
                      Text(
                        'per ticket',
                        style:
                            TextStyle(color: Colors.white24, fontSize: 8.5.sp),
                      ),
                  ],
                ),

                SizedBox(width: 3.w),

                // Counter
                if (tier.isSoldOut)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(1.5.h),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Text('—',
                        style:
                            TextStyle(color: Colors.red, fontSize: 11.sp)),
                  )
                else
                  _buildCounter(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Counter ────────────────────────────────────────────────────────────────
  Widget _buildCounter(int index) {
    final qty = _localTiers[index].selectedQuantity;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _counterBtn(
          icon: Icons.remove_rounded,
          active: qty > 0,
          onTap: () => _adjustQty(index, -1),
        ),
        Container(
          width: 9.w,
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$qty',
              key: ValueKey(qty),
              style: TextStyle(
                color: qty > 0 ? Colors.white : Colors.white38,
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        _counterBtn(
          icon: Icons.add_rounded,
          active: true,
          onTap: () => _adjustQty(index, 1),
        ),
      ],
    );
  }

  Widget _counterBtn(
      {required IconData icon,
      required bool active,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: active
              ? AppColors.blueColor.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(1.h),
          border: Border.all(
            color: active
                ? AppColors.blueColor.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.blueColor : Colors.white24,
          size: 14.sp,
        ),
      ),
    );
  }

  // ── Sticky bottom bar ──────────────────────────────────────────────────────
  Widget _buildStickyBottom() {
    final hasSelection = _totalCount > 0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 3.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _summaryText,
                          style: TextStyle(
                            color: hasSelection
                                ? Colors.white70
                                : Colors.white30,
                            fontSize: 10.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasSelection) ...[
                          SizedBox(height: 0.4.h),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // CTA Button
                  GestureDetector(
                    onTap: hasSelection ? _onContinue : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 1.8.h),
                      decoration: BoxDecoration(
                        gradient: hasSelection
                            ? LinearGradient(
                                colors: [
                                  AppColors.blueColor,
                                  AppColors.blueColor
                                      .withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: hasSelection
                            ? null
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(4.h),
                        boxShadow: hasSelection
                            ? [
                                BoxShadow(
                                  color: AppColors.blueColor
                                      .withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color:
                                  hasSelection ? Colors.white : Colors.white30,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color:
                                hasSelection ? Colors.white : Colors.white30,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
