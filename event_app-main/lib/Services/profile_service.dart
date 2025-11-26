import 'dart:convert';
import 'dart:io';
import 'package:event_app/MVVM/body_model/ViewProfileModel.dart';
import 'package:event_app/MVVM/body_model/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class UserService {
  static const String baseUrl = 'https://eventgo-live.com/api/v1';

  /// 🔷 Fetch Public Profile by userId
  Future<ViewPublicProfileModel?> fetchPublicProfile(int? id) async {
    if (id == null) {
      print('❌ fetchPublicProfile called with null id');
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/user/$id');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ViewPublicProfileModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  /// 🔷 Fetch Current Logged-in User Profile
  Future<ProfileModel> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/user');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('[fetchProfile] Response: $jsonResponse');
      return ProfileModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  /// 🔷 Update User Profile (Edit Profile)
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? shortBio,
    List<String>? interests,
    File? profileImage,
    String? phoneNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var uri = Uri.parse('$baseUrl/user/update');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      // Add fields if not null
      if (name != null) request.fields['name'] = name;
      if (shortBio != null) request.fields['shortBio'] = shortBio;
      if (phoneNumber != null) request.fields['phoneNumber'] = phoneNumber;

      if (interests != null && interests.isNotEmpty) {
        // Send as array (Laravel reads interests[0], interests[1] as array)
        for (int i = 0; i < interests.length; i++) {
          request.fields['interests[$i]'] = interests[i];
        }
      }

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
          filename: basename(profileImage.path),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[updateUserProfile] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('❌ Error in updateUserProfile: $e');
      rethrow;
    }
  }
}
