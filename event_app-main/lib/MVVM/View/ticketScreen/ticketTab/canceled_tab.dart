import 'package:event_app/MVVM/view_model/ticket_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../Widget/ticket_card.dart';

class CancelledTab extends StatelessWidget {
  final TicketViewModel ticketVM = Get.find<TicketViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ticketVM.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blueColor),
        );
      }

      // Filter tickets by cancelled/canceled status
      final cancelledTickets = ticketVM.tickets.where((ticket) {
        final status = (ticket['status'] ?? '').toString().toLowerCase();
        return status.contains('cancel') ||
            status.contains('refund') ||
            status == 'cancelled' ||
            status == 'canceled';
      }).toList();

      if (cancelledTickets.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(5.h),
            child: Text(
              "No cancelled tickets",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(2.h),
        itemCount: cancelledTickets.length,
        itemBuilder: (context, index) {
          final ticket = cancelledTickets[index];
          final eventTitle = ticket['eventTitle'] ?? 'Event';
          final startDate = ticket['startDate'] ?? '';
          final startTime = ticket['startTime'] ?? '';
          final endTime = ticket['endTime'] ?? '';
          final address = ticket['address'] ?? '';
          final city = ticket['city'] ?? '';
          final eventImage = ticket['eventImage'] ?? '';
          final status = ticket['status'] ?? 'Cancelled';

          // Format date
          String formattedDate = 'Date TBA';
          if (startDate.isNotEmpty) {
            try {
              final date = DateTime.parse(startDate);
              formattedDate = DateFormat('EEE, MMM d').format(date);

              // Add time if available
              if (startTime.isNotEmpty && endTime.isNotEmpty) {
                try {
                  final start = DateFormat("HH:mm:ss").parse(startTime);
                  final end = DateFormat("HH:mm:ss").parse(endTime);
                  formattedDate +=
                      ' · ${DateFormat.jm().format(start)} - ${DateFormat.jm().format(end)}';
                } catch (e) {
                  // If time parsing fails, just use date
                }
              }
            } catch (e) {
              formattedDate = startDate;
            }
          }

          // Format location
          String location = 'Location TBA';
          if (address.isNotEmpty && city.isNotEmpty) {
            location = '$address, $city';
          } else if (city.isNotEmpty) {
            location = city;
          } else if (address.isNotEmpty) {
            location = address;
          }

          // Truncate location if too long
          if (location.length > 30) {
            location = '${location.substring(0, 27)}...';
          }

          // Build image URL
          String? imageUrl;
          if (eventImage.isNotEmpty) {
            imageUrl = eventImage.startsWith('http')
                ? eventImage
                : 'https://eventgo-live.com$eventImage';
          }

          return TicketCard(
            title: eventTitle,
            date: formattedDate,
            location: location,
            imageUrl: imageUrl,
            status: status.toString(),
            completed: false,
          );
        },
      );
    });
  }
}
