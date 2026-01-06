import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:media_store_plus/media_store_plus.dart';

Future<void> generateTicketPdf(Map<String, dynamic> ticketData) async {
  final pdf = pw.Document();

  // 🔷 Request storage permission
  var status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    throw Exception("Storage permission not granted");
  }

  // 🔷 Initialize MediaStore
  MediaStore.appFolder = "EventGo";

  final mediaStore = MediaStore();

  // 🔷 Load fonts
  final interRegular =
      pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
  final interBold =
      pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));

  // 🔷 Load event image
  Uint8List? eventImageData;
  final String? eventImagePath = ticketData['eventImage'];
  if (eventImagePath != null) {
    final String eventImageUrl = "https://eventgo-live.com$eventImagePath";
    try {
      final response = await http.get(Uri.parse(eventImageUrl));
      if (response.statusCode == 200) {
        eventImageData = response.bodyBytes;
      }
    } catch (e) {
      print("Failed to load event image: $e");
    }
  }

  // 🔷 Ticket data
  final eventTitle = ticketData['eventTitle'] ?? 'Event Name';
  final date = ticketData['startDate'] ?? '11.11.2020';
  final time = ticketData['startTime'] ?? '09:00 PM';
  final price =
      (ticketData['eventPrice']?.toString() ?? '50').replaceAll('\$', '');
  final ticketType = ticketData['ticketType'] ?? 'VIP';
  final ticketNumber = ticketData['ticketNumber'] ?? 'EVT123456';
  final address = ticketData['address'] ?? '';
  final city = ticketData['city'] ?? '';
  final qrCodeData = ticketData['qrCodeData'] ?? ''; // Get QR code data from API

  final venue = (address.isNotEmpty && city.isNotEmpty)
      ? '$address, $city'
      : (address.isNotEmpty ? address : (city.isNotEmpty ? city : 'N/A'));

  // 🔷 Generate QR code image bytes
  Uint8List? qrCodeImageBytes;
  if (qrCodeData.isNotEmpty) {
    try {
      // Use online QR code API to generate QR code image
      final qrDataString = qrCodeData is String ? qrCodeData : jsonEncode(qrCodeData);
      final qrCodeUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(qrDataString)}';
      final qrResponse = await http.get(Uri.parse(qrCodeUrl));
      if (qrResponse.statusCode == 200) {
        qrCodeImageBytes = qrResponse.bodyBytes;
      }
    } catch (e) {
      print("Failed to generate QR code image: $e");
    }
  }

  // 🔷 Format dates and times
  String formattedStartDate = date.isNotEmpty
      ? DateFormat('dd MMM yyyy').format(DateTime.parse(date))
      : 'N/A';
  String formattedStartTime = time.isNotEmpty
      ? DateFormat.jm().format(DateFormat("HH:mm:ss").parse(time))
      : 'N/A';
  // 🔷 Create PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a6,
      build: (pw.Context context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
          ),
          child: pw.Stack(
            children: [
              // 🔷 Event Image as background
              eventImageData != null
                  ? pw.Positioned.fill(
                      child: pw.ClipRRect(
                        horizontalRadius: 12,
                        verticalRadius: 12,
                        child: pw.Image(
                          pw.MemoryImage(eventImageData),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    )
                  : pw.Positioned.fill(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text("EVENT IMAGE",
                            style: pw.TextStyle(
                              font: interBold,
                              color: PdfColors.grey700,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            )),
                      ),
                    ),

              // 🔷 Dark overlay
              pw.Positioned.fill(
                child: pw.Opacity(
                  opacity: 0.3,
                  child: pw.Container(
                    color: PdfColors.black,
                  ),
                ),
              ),

              // 🔷 Ticket details
              pw.Padding(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Event title
                    pw.Text(
                      eventTitle,
                      style: pw.TextStyle(
                        font: interBold,
                        fontSize: 20,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    // Venue
                    pw.Text(
                      venue,
                      style: pw.TextStyle(
                        font: interRegular,
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Spacer(),

                    // Date, Time, and Ticket Type row
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(0, 0, 0, 0.7),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("DATE",
                                  style: pw.TextStyle(
                                    font: interRegular,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  )),
                              pw.Text(formattedStartDate,
                                  style: pw.TextStyle(
                                    font: interBold,
                                    fontSize: 12,
                                    color: PdfColors.white,
                                  )),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("TIME",
                                  style: pw.TextStyle(
                                    font: interRegular,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  )),
                              pw.Text(formattedStartTime,
                                  style: pw.TextStyle(
                                    font: interBold,
                                    fontSize: 12,
                                    color: PdfColors.white,
                                  )),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("TYPE",
                                  style: pw.TextStyle(
                                    font: interRegular,
                                    fontSize: 8,
                                    color: PdfColors.white,
                                  )),
                              pw.Text(ticketType,
                                  style: pw.TextStyle(
                                    font: interBold,
                                    fontSize: 12,
                                    color: PdfColors.white,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 12),

                    // Ticket number and price
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Ticket #: $ticketNumber",
                          style: pw.TextStyle(
                            font: interRegular,
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          '\$$price',
                          style: pw.TextStyle(
                            font: interBold,
                            fontSize: 18,
                            color: PdfColors.greenAccent400,
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 16),

                    // QR Code
                    if (qrCodeImageBytes != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Scan for verification',
                              style: pw.TextStyle(
                                font: interRegular,
                                fontSize: 8,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Image(
                              pw.MemoryImage(qrCodeImageBytes),
                              width: 120,
                              height: 120,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Ticket: $ticketNumber',
                              style: pw.TextStyle(
                                font: interRegular,
                                fontSize: 7,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Fallback: Show ticket number if QR code not available
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'Ticket: $ticketNumber\n(QR Code not available)',
                          style: pw.TextStyle(
                            font: interRegular,
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // 🔷 Save PDF to temporary file
  final pdfBytes = await pdf.save();
  final tempDir = await getTemporaryDirectory();
  final tempFilePath = "${tempDir.path}/Ticket-$ticketNumber.pdf";
  final tempFile = File(tempFilePath);
  await tempFile.writeAsBytes(pdfBytes);

  // 🔷 Save using media_store_plus
  try {
    final saveInfo = await mediaStore.saveFile(
      tempFilePath: tempFilePath,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    if (saveInfo != null) {
      print("✅ Ticket PDF saved. Path: $saveInfo");
    } else {
      print("❌ Failed to save PDF: saveInfo is null");
    }
  } catch (e) {
    print("❌ Exception while saving PDF: $e");
  }
}
