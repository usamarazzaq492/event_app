import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DataService {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

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
        ? "https://eventgo-live.com/api/v1/user/$userId/unfollow"
        : "https://eventgo-live.com/api/v1/user/$userId/follow";

    print('🔷 ${isFollowing ? 'Unfollow' : 'Follow'} Request: $url');
    print('🔷 Token: ${token.substring(0, 20)}...');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("🔷 ${isFollowing ? 'Unfollow' : 'Follow'} Status: ${response.statusCode}");
    print("🔷 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("🔷 Response Data: $responseData");
      
      // Check if response indicates success
      if (responseData['success'] == false) {
        throw Exception(responseData['error'] ?? 'Failed to ${isFollowing ? 'unfollow' : 'follow'} user');
      }
      
      return responseData;
    } else {
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : {'error': 'Unknown error'};
      throw Exception(errorBody['error'] ?? "Failed to ${isFollowing ? 'unfollow' : 'follow'}: ${response.statusCode}");
    }
  }



  static Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String shortBio,
    required String interests,
    required File profileImage,
    required String phoneNumber,
  }) async {
    var uri = Uri.parse('$baseUrl/user/update');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('token ${token}');
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })      ..fields['name'] = name
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