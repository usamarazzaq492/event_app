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
    print('token $token');

    final url = isFollowing
        ? "https://eventgo-live.com/api/v1/user/$userId/unfollow"
        : "https://eventgo-live.com/api/v1/user/$userId/follow";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("${isFollowing ? 'Unfollow' : 'Follow'} Status: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to ${isFollowing ? 'unfollow' : 'follow'}: ${response.body}");
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