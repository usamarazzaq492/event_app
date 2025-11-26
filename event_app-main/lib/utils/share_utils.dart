import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShareUtils {
  /// Share event with enhanced content
  static Future<void> shareEvent({
    required String eventTitle,
    required String eventDescription,
    required String eventDate,
    required String eventTime,
    required String eventLocation,
    required String eventImageUrl,
    String? eventUrl,
    String? organizerName,
  }) async {
    final formattedDate = _formatDate(eventDate);
    final formattedTime = _formatTime(eventTime);

    final shareText = '''
🎉 Check out this amazing event!

📅 **$eventTitle**
🗓️ $formattedDate at $formattedTime
📍 $eventLocation
${organizerName != null ? '👤 Organized by $organizerName' : ''}

${eventDescription.isNotEmpty ? '📝 $eventDescription' : ''}

${eventUrl != null ? '🔗 $eventUrl' : ''}

#EventGo #Events #${eventTitle.replaceAll(' ', '')}
''';

    await Share.share(
      shareText,
      subject: 'Check out this event: $eventTitle',
    );
  }

  /// Share event with image
  static Future<void> shareEventWithImage({
    required String eventTitle,
    required String eventDescription,
    required String eventDate,
    required String eventTime,
    required String eventLocation,
    required String eventImageUrl,
    String? eventUrl,
    String? organizerName,
  }) async {
    final formattedDate = _formatDate(eventDate);
    final formattedTime = _formatTime(eventTime);

    final shareText = '''
🎉 Check out this amazing event!

📅 **$eventTitle**
🗓️ $formattedDate at $formattedTime
📍 $eventLocation
${organizerName != null ? '👤 Organized by $organizerName' : ''}

${eventDescription.isNotEmpty ? '📝 $eventDescription' : ''}

${eventUrl != null ? '🔗 $eventUrl' : ''}

#EventGo #Events #${eventTitle.replaceAll(' ', '')}
''';

    // Note: For sharing with images, you would need to implement
    // a custom share sheet or use a different package that supports
    // sharing both text and images together
    await Share.share(
      shareText,
      subject: 'Check out this event: $eventTitle',
    );
  }

  /// Share app with referral
  static Future<void> shareApp({
    String? referralCode,
    String? customMessage,
  }) async {
    final message = customMessage ??
        '''
🎉 Discover amazing events with EventGo!

EventGo is the best app to find and book tickets for events in your city. From concerts and sports to conferences and workshops - we've got it all!

${referralCode != null ? 'Use my referral code: $referralCode' : ''}

Download now and never miss out on great events again!

#EventGo #Events #DiscoverEvents
''';

    await Share.share(
      message,
      subject: 'Check out EventGo - The best event discovery app!',
    );
  }

  /// Share event ticket
  static Future<void> shareTicket({
    required String eventTitle,
    required String eventDate,
    required String eventTime,
    required String eventLocation,
    required String ticketType,
    required String ticketPrice,
    required String ticketId,
    String? qrCodeData,
  }) async {
    final formattedDate = _formatDate(eventDate);
    final formattedTime = _formatTime(eventTime);

    final shareText = '''
🎫 My Event Ticket

📅 **$eventTitle**
🗓️ $formattedDate at $formattedTime
📍 $eventLocation
🎫 $ticketType - $ticketPrice
🆔 Ticket ID: $ticketId

${qrCodeData != null ? '📱 QR Code: $qrCodeData' : ''}

See you at the event! 🎉

#EventGo #MyTicket #$eventTitle
''';

    await Share.share(
      shareText,
      subject: 'My ticket for $eventTitle',
    );
  }

  /// Share event collection/favorites
  static Future<void> shareEventCollection({
    required String collectionName,
    required List<Map<String, dynamic>> events,
    String? description,
  }) async {
    final eventList = events.take(5).map((event) {
      final date = _formatDate(event['date'] ?? '');
      final time = _formatTime(event['time'] ?? '');
      return '• ${event['title']} - $date at $time';
    }).join('\n');

    final shareText = '''
📚 My Event Collection: $collectionName

${description != null ? '📝 $description\n' : ''}
🎉 Events I'm excited about:

$eventList

${events.length > 5 ? '... and ${events.length - 5} more events!' : ''}

Check out EventGo to discover more amazing events!

#EventGo #MyCollection #Events
''';

    await Share.share(
      shareText,
      subject: 'My event collection: $collectionName',
    );
  }

  /// Share event feedback/review
  static Future<void> shareEventReview({
    required String eventTitle,
    required int rating,
    required String review,
    String? eventImageUrl,
  }) async {
    final stars = '⭐' * rating;

    final shareText = '''
⭐ Event Review: $eventTitle

$stars ($rating/5)

"$review"

Check out this amazing event on EventGo!

#EventGo #EventReview #$eventTitle
''';

    await Share.share(
      shareText,
      subject: 'My review of $eventTitle',
    );
  }

  /// Share event invitation
  static Future<void> shareEventInvitation({
    required String eventTitle,
    required String eventDate,
    required String eventTime,
    required String eventLocation,
    required String inviterName,
    String? personalMessage,
  }) async {
    final formattedDate = _formatDate(eventDate);
    final formattedTime = _formatTime(eventTime);

    final shareText = '''
🎉 You're invited to an event!

$inviterName has invited you to:

📅 **$eventTitle**
🗓️ $formattedDate at $formattedTime
📍 $eventLocation

${personalMessage != null ? '💬 "$personalMessage"\n' : ''}
Join me at this amazing event! Download EventGo to get your ticket.

#EventGo #EventInvitation #$eventTitle
''';

    await Share.share(
      shareText,
      subject: 'You\'re invited to $eventTitle',
    );
  }

  /// Share event reminder
  static Future<void> shareEventReminder({
    required String eventTitle,
    required String eventDate,
    required String eventTime,
    required String eventLocation,
    String? reminderMessage,
  }) async {
    final formattedDate = _formatDate(eventDate);
    final formattedTime = _formatTime(eventTime);

    final shareText = '''
⏰ Event Reminder

Don't forget about this upcoming event:

📅 **$eventTitle**
🗓️ $formattedDate at $formattedTime
📍 $eventLocation

${reminderMessage != null ? '💬 $reminderMessage\n' : ''}
See you there! 🎉

#EventGo #EventReminder #$eventTitle
''';

    await Share.share(
      shareText,
      subject: 'Reminder: $eventTitle',
    );
  }

  /// Share event statistics
  static Future<void> shareEventStats({
    required int totalEvents,
    required int eventsAttended,
    required int favoriteCategories,
    required String topCategory,
    String? year,
  }) async {
    final yearText = year ?? DateTime.now().year.toString();

    final shareText = '''
📊 My EventGo Year in Review ($yearText)

🎉 Total Events: $totalEvents
✅ Events Attended: $eventsAttended
❤️ Favorite Categories: $favoriteCategories
🏆 Top Category: $topCategory

What an amazing year of events! Thanks EventGo for helping me discover so many great experiences.

#EventGo #YearInReview #$yearText #EventStats
''';

    await Share.share(
      shareText,
      subject: 'My EventGo Year in Review',
    );
  }

  /// Format date for sharing
  static String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('EEEE, MMM d, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  /// Format time for sharing
  static String _formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  /// Get share options for different platforms
  static List<ShareOption> getShareOptions() {
    return [
      ShareOption(
        platform: 'WhatsApp',
        icon: Icons.chat,
        color: Colors.green,
      ),
      ShareOption(
        platform: 'Facebook',
        icon: Icons.facebook,
        color: Colors.blue,
      ),
      ShareOption(
        platform: 'Twitter',
        icon: Icons.alternate_email,
        color: Colors.blue,
      ),
      ShareOption(
        platform: 'Instagram',
        icon: Icons.camera_alt,
        color: Colors.purple,
      ),
      ShareOption(
        platform: 'LinkedIn',
        icon: Icons.business,
        color: Colors.blue.shade700,
      ),
      ShareOption(
        platform: 'Telegram',
        icon: Icons.send,
        color: Colors.blue,
      ),
      ShareOption(
        platform: 'Email',
        icon: Icons.email,
        color: Colors.grey,
      ),
      ShareOption(
        platform: 'SMS',
        icon: Icons.sms,
        color: Colors.green,
      ),
    ];
  }
}

class ShareOption {
  final String platform;
  final IconData icon;
  final Color color;

  ShareOption({
    required this.platform,
    required this.icon,
    required this.color,
  });
}
