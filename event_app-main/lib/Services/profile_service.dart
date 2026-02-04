import 'dart:convert';
import 'dart:io';
import 'package:event_app/MVVM/body_model/ViewProfileModel.dart';
import 'package:event_app/MVVM/body_model/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class UserService {
  static const String baseUrl = 'https://eventgo-live.com/api/v1';

  /// 🔷 Fetch Public Profile by userId (works without auth for guests)
  Future<ViewPublicProfileModel?> fetchPublicProfile(int? id) async {
    if (id == null) {
      print('❌ fetchPublicProfile called with null id');
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/user/$id');
    print('🔷 Fetching public profile: $uri');

    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(uri, headers: headers);

    print('🔷 Profile API Response Status: ${response.statusCode}');
    print('🔷 Profile API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('🔷 Parsed JSON: $jsonData');
      final profile = ViewPublicProfileModel.fromJson(jsonData);
      print(
          '🔷 Parsed Profile - isFollowing: ${profile.isFollowing}, followersCount: ${profile.followersCount}');
      return profile;
    } else {
      print(
          '❌ Failed to fetch profile: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  /// 🔷 Fetch Current Logged-in User Profile
  Future<ProfileModel> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in again.');
      }

      final uri = Uri.parse('$baseUrl/user');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Connection timeout. Please check your internet connection.');
        },
      );

      final jsonResponse = json.decode(response.body);
      print(
          '[fetchProfile] Status: ${response.statusCode}, Response: $jsonResponse');

      if (response.statusCode == 200) {
        // Check if API returned success: false
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['success'] == false) {
          final errorMessage =
              jsonResponse['message'] ?? 'Failed to load profile';
          throw Exception(errorMessage);
        }
        if (jsonResponse is! Map) {
          throw Exception('Invalid profile response from server.');
        }
        try {
          return ProfileModel.fromJson(Map<String, dynamic>.from(jsonResponse));
        } catch (e) {
          throw Exception('Failed to load profile. Please try again.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Profile not found.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorMessage = jsonResponse['message'] ??
            'Failed to load profile (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Network error. Please check your connection.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to load profile: ${e.toString()}');
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

      print(
          '[updateUserProfile] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to update profile: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('❌ Error in updateUserProfile: $e');
      rethrow;
    }
  }
}
