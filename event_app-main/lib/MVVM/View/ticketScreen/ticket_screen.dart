import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/ticket_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../Services/ticket_pdf_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TicketViewModel ticketVM = Get.put(TicketViewModel());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ticketVM.getTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
                child: Row(
                  children: [
                    Text("My Tickets", style: TextStyles.tickettext),
                    const Spacer(),
                  ],
                ),
              ),
              const TabBar(
                labelColor: Colors.white,
                indicatorColor: AppColors.blueColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'General'),
                  Tab(text: 'Silver'),
                  Tab(text: 'Gold'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTicketList('general'),
                    _buildTicketList('silver'),
                    _buildTicketList('gold'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(String type) {
    return Obx(() {
      if (ticketVM.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blueColor),
        );
      }

      final filtered = ticketVM.tickets
          .where((ticket) => ticket['ticketType'] == type)
          .toList();

      if (filtered.isEmpty) {
        return Center(
          child: Text(
            "No $type tickets",
            style: const TextStyle(color: Colors.white),
          ),
        );
      }

      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final t = filtered[index];
          final imageUrl = "https://eventgo-live.com${t['eventImage'] ?? ''}";
          final eventTitle = t['eventTitle'] ?? 'No Title';
          final capitalizedTitle = eventTitle.isNotEmpty
              ? eventTitle[0].toUpperCase() + eventTitle.substring(1)
              : eventTitle;
          final ticketType = t['ticketType'] ?? 'Unknown';
          final startDate = t['startDate'] ?? '';
          final endDate = t['endDate'] ?? '';
          final startTime = t['startTime'] ?? '';
          final endTime = t['endTime'] ?? '';
          final ticketNumber = t['ticketNumber'] ?? 'N/A';
          final eventPrice = t['eventPrice']?.toString() ?? 'N/A';

          // 🔷 Format dates and times
          String formattedStartDate = startDate.isNotEmpty
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(startDate))
              : 'N/A';
          String formattedEndDate = endDate.isNotEmpty
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(endDate))
              : 'N/A';
          String formattedStartTime = startTime.isNotEmpty
              ? DateFormat.jm().format(DateFormat("HH:mm:ss").parse(startTime))
              : 'N/A';
          String formattedEndTime = endTime.isNotEmpty
              ? DateFormat.jm().format(DateFormat("HH:mm:ss").parse(endTime))
              : 'N/A';

          return Card(
            color: AppColors.signinoptioncolor,
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    capitalizedTitle,
                    style: TextStyle(
                      color: AppColors.blueColor, // 🔷 Attractive title color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "${ticketType[0].toUpperCase()}${ticketType.substring(1)} | $formattedStartDate - $formattedEndDate",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Time: $formattedStartTime - $formattedEndTime",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Price: \$$eventPrice",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Ticket #: $ticketNumber",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 130),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text(
                      "Download Ticket",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: () async {
                      try {
                        await generateTicketPdf(t);
                        Get.snackbar("Download Complete",
                            "Ticket saved to Downloads folder");
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
