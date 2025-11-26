import 'dart:convert';
import 'dart:io';
import 'package:event_app/MVVM/body_model/ads_model.dart';
import 'package:event_app/MVVM/body_model/ad_detail_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  final String baseUrl = "https://eventgo-live.com/api/v1";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> addAd({
    required String title,
    required String description,
    required String targetAmount,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/ads/add');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _getHeaders());

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['target_amount'] = targetAmount;

    final mimeType = lookupMimeType(imageFile.path)?.split('/');
    request.files.add(await http.MultipartFile.fromPath(
      'imageUrl',
      imageFile.path,
      contentType: mimeType != null
          ? MediaType(mimeType[0], mimeType[1])
          : MediaType('image', 'jpeg'),
    ));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      return {'success': true, 'body': res.body};
    } else {
      throw Exception("Failed to upload ad: ${res.body}");
    }
  }

  Future<List<AdsModel>> fetchAds() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse("$baseUrl/ads"), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AdsModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch ads: ${response.body}");
    }
  }

  Future<AdsDetailModel> fetchAdDetail(int? adId) async {
    if (adId == null) throw Exception('Ad ID cannot be null');

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/ads/$adId'), headers: headers);

    if (response.statusCode == 200) {
      return AdsDetailModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load ad detail: ${response.body}');
    }
  }
}
