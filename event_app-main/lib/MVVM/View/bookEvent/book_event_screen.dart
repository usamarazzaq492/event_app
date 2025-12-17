import 'package:event_app/MVVM/View/paymentMethod/payment_method.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BookEventScreen extends StatefulWidget {
  final int? id;

  const BookEventScreen({super.key, required this.id});

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int seatCount = 1;
  final TextEditingController _seatCountController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _seatCountController.dispose();
    super.dispose();
  }

  void _updateSeatCount(int newCount) {
    if (newCount < 1) {
      newCount = 1;
    }
    // Removed upper limit to allow users to type larger numbers like 25
    setState(() {
      seatCount = newCount;
      _seatCountController.text = newCount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('event id ${widget.id}');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(top: 7.h, left: 4.w, right: 4.w, bottom: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10.w),
                  Text('Book Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        fontSize: 18.sp,
                      )),
                ],
              ),
              SizedBox(height: 4.h),

              // 🔷 TabBar Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C23),
                  borderRadius: BorderRadius.circular(2.h),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.blueColor,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: AppColors.blueColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  tabs: const [
                    Tab(text: 'General'),
                    Tab(text: 'Silver'),
                    Tab(text: 'Gold'),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // 🔷 Seat selection label
              Text(
                'Choose number of tickets',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // 🔷 Counter with Text Input
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C23),
                  borderRadius: BorderRadius.circular(2.h),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(Icons.remove, () {
                      _updateSeatCount(seatCount - 1);
                    }),
                    const SizedBox(width: 20),
                    // TextField for direct input
                    Expanded(
                      child: TextField(
                        controller: _seatCountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        onChanged: (value) {
                          // Allow typing without immediate validation
                          // Only update if it's a valid number
                          final intValue = int.tryParse(value);
                          if (intValue != null && intValue >= 1) {
                            setState(() {
                              seatCount = intValue;
                            });
                          }
                        },
                        onEditingComplete: () {
                          // Validate when user finishes editing
                          final intValue =
                              int.tryParse(_seatCountController.text);
                          if (intValue == null || intValue < 1) {
                            _updateSeatCount(1);
                          } else {
                            _updateSeatCount(intValue);
                          }
                          FocusScope.of(context).unfocus();
                        },
                        onSubmitted: (value) {
                          // Handle when user presses done/enter
                          final intValue = int.tryParse(value);
                          if (intValue == null || intValue < 1) {
                            _updateSeatCount(1);
                          } else {
                            _updateSeatCount(intValue);
                          }
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildCounterButton(Icons.add, () {
                      _updateSeatCount(seatCount + 1);
                    }),
                  ],
                ),
              ),
              SizedBox(height: 6.h),

              // 🔷 Continue Button
              ButtonWidget(
                text: 'Continue',
                onPressed: () {
                  String ticketType;
                  switch (_tabController.index) {
                    case 0:
                      ticketType = 'general';
                      break;
                    case 1:
                      ticketType = 'silver';
                      break;
                    case 2:
                      ticketType = 'gold';
                      break;
                    default:
                      ticketType = 'general';
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentMethodScreen(
                        category: ticketType,
                        seats: seatCount,
                        id: widget.id,
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.blueColor,
                textColor: AppColors.whiteColor,
                borderRadius: 4.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Counter Button Widget
  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueColor, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.blueColor),
        onPressed: onPressed,
        iconSize: 28,
      ),
    );
  }
}
