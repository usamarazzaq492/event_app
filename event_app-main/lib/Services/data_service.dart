import 'dart:convert';
import 'dart:io';
import 'package:event_app/app/config/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static Future<Map<String, dynamic>> toggleFollow({
    required int userId,
    required bool isFollowing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final url = isFollowing
        ? "${AppUrl.userProfile}/$userId/unfollow"
        : "${AppUrl.userProfile}/$userId/follow";

    debugPrint('🔷 ${isFollowing ? 'Unfollow' : 'Follow'} Request: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint(
        "🔷 ${isFollowing ? 'Unfollow' : 'Follow'} Status: ${response.statusCode}");
    debugPrint("🔷 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint("🔷 Response Data: $responseData");

      // Check if response indicates success
      if (responseData['success'] == false) {
        throw Exception(responseData['error'] ??
            'Failed to ${isFollowing ? 'unfollow' : 'follow'} user');
      }

      return responseData;
    } else {
      final errorBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {'error': 'Unknown error'};
      throw Exception(errorBody['error'] ??
          "Failed to ${isFollowing ? 'unfollow' : 'follow'}: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String shortBio,
    required String interests,
    required File profileImage,
    required String phoneNumber,
  }) async {
    var uri = Uri.parse(AppUrl.updateUserProfile);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields['name'] = name
      ..fields['shortBio'] = shortBio
      ..fields['interests[]'] = interests
      ..fields['phoneNumber'] = phoneNumber
      ..files.add(await http.MultipartFile.fromPath(
        'profileImage',
        profileImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to update profile: $responseBody');
    }
  }
}
