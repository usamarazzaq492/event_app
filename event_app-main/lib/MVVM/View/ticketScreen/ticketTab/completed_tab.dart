import 'package:event_app/MVVM/view_model/ticket_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../Widget/ticket_card.dart';

class CompletedTab extends StatelessWidget {
  final TicketViewModel ticketVM = Get.find<TicketViewModel>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ticketVM.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blueColor),
        );
      }

      // Filter tickets by status - completed, finished, or past events
      final completedTickets = ticketVM.tickets.where((ticket) {
        final status = (ticket['status'] ?? '').toString().toLowerCase();
        final eventDate = ticket['endDate'] ?? ticket['startDate'] ?? '';
        
        // Check if status indicates completion or if event date has passed
        if (status.contains('completed') || 
            status.contains('finished') || 
            status.contains('done')) {
          return true;
        }
        
        // Check if event date has passed
        if (eventDate.isNotEmpty) {
          try {
            final eventDateTime = DateTime.parse(eventDate);
            if (eventDateTime.isBefore(DateTime.now())) {
              return true;
            }
          } catch (e) {
            // If date parsing fails, skip this check
          }
        }
        
        return false;
      }).toList();

      if (completedTickets.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(5.h),
            child: Text(
              "No completed tickets",
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
        itemCount: completedTickets.length,
        itemBuilder: (context, index) {
          final ticket = completedTickets[index];
          final eventTitle = ticket['eventTitle'] ?? 'Event';
          final startDate = ticket['startDate'] ?? '';
          final endDate = ticket['endDate'] ?? '';
          final startTime = ticket['startTime'] ?? '';
          final endTime = ticket['endTime'] ?? '';
          final address = ticket['address'] ?? '';
          final city = ticket['city'] ?? '';
          final eventImage = ticket['eventImage'] ?? '';
          final status = ticket['status'] ?? 'Completed';

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
                  formattedDate += ' · ${DateFormat.jm().format(start)} - ${DateFormat.jm().format(end)}';
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
            completed: true,
          );
        },
      );
    });
  }
}
