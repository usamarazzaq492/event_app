import 'package:event_app/app/config/app_asset.dart';
import 'package:flutter/material.dart';

import '../../../../Widget/ticket_card.dart';


class CompletedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        TicketCard(
          title: "Art & Painting Training",
          date: "Tue, Dec 26 · 18:00 - 21:00 PM",
          location: "Central Art...",
          imagePath: AppImages.img4,
          status: "Completed",
          completed: true,
        ),
        TicketCard(
          title: "DJ & Music Concert",
          date: "Tue, Dec 30 · 18:00 - 22:00 PM",
          location: "New Avenue...",
          imagePath: AppImages.img4,
          status: "Completed",
          completed: true,
        ),
        TicketCard(
          title: "Fitness & Gym Training",
          date: "Sun, Dec 24 · 19:00 - 23:00 PM",
          location: "Grand Build...",
          imagePath: AppImages.img4,
          status: "Completed",
          completed: true,
        ),
      ],
    );
  }
}
