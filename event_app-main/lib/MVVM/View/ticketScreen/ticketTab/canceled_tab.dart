import 'package:flutter/material.dart';

import '../../../../Widget/ticket_card.dart';
import '../../../../app/config/app_asset.dart';


class CancelledTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TicketCard(
          title: "Traditional Dance Festival",
          date: "Tue, Dec 16 · 18:00 - 22:00 PM",
          location: "New Avenue...",
          imagePath: AppImages.img4,
          status: "Cancelled",
        ),

        TicketCard(
          title: "Painting Workshops",
          date: "Sun, Dec 23 · 19:00 - 23:00 PM",
          location: "Grand Park...",
          imagePath: AppImages.img4,
          status: "Cancelled",
        ),
        TicketCard(
          title: "Gebyar Music Festival",
          date: "Thu, Dec 20 · 17:00 - 22:00 PM",
          location: "Central Hall...",
          imagePath: AppImages.img4,
          status: "Cancelled",
        ),
        TicketCard(
          title: "National Concert of...",
          date: "Wed, Dec 18 · 18:00 - 22:00 PM",
          location: "Central Park...",
          imagePath: AppImages.img4,
          status: "Cancelled",
        ),
      ],
    );
  }
}
