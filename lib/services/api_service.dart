import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://192.168.1.2:5000';

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);
      return null;
    }

    return data['message'] ?? 'Login failed';
  }

  static Future<bool> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendOtp(String phone, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'email': email,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> resetPassword(
    String email,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': newPassword,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getAnimals(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/animals?category=$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getMyAds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/ads/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  static Future<List<dynamic>> getPendingAds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('$baseUrl/api/ads/pending'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<void> approveAd(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse('$baseUrl/api/ads/$id/approve'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<void> rejectAd(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse('$baseUrl/api/ads/$id/reject'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<bool> addAd({
    required String name,
    required String description,
    required String price,
    required String category,
    required List<File> images,
    required File idCard,
    String? age,
    bool? vaccinated,
    String? healthStatus,
    String? location,
  }) async {
    final uri = Uri.parse('$baseUrl/api/ads');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print(' NO TOKEN FOUND');
      return false;
    }

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    });

    if (age != null) request.fields['age'] = age;
    if (vaccinated != null) {
      request.fields['vaccinated'] = vaccinated.toString();
    }
    if (healthStatus != null) request.fields['healthStatus'] = healthStatus;
    if (location != null) request.fields['location'] = location;

    for (final img in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images', img.path),
      );
    }

    request.files.add(
      await http.MultipartFile.fromPath('idCard', idCard.path),
    );

    final response = await request.send();
    print('ADD AD STATUS: ${response.statusCode}');

    return response.statusCode == 201;
  }

  static Future<bool> updateAd({
    required String id,
    required String name,
    required String description,
    required String price,
    required String category,
    required List<File> newImages,
    String? age,
    bool? vaccinated,
    String? healthStatus,
    String? location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final request =
        http.MultipartRequest('PATCH', Uri.parse('$baseUrl/api/ads/$id'));

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    });

    if (age != null) request.fields['age'] = age;
    if (vaccinated != null) {
      request.fields['vaccinated'] = vaccinated.toString();
    }
    if (healthStatus != null) request.fields['healthStatus'] = healthStatus;
    if (location != null) request.fields['location'] = location;

    for (final img in newImages) {
      request.files.add(
        await http.MultipartFile.fromPath('images', img.path),
      );
    }

    final response = await request.send();
    print('UPDATE AD STATUS: ${response.statusCode}');

    return response.statusCode == 200;
  }

  static Future<bool> deleteAd(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/api/ads/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getAdStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('$baseUrl/api/ads/stats'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return {};
  }

  static Future<List<dynamic>> getApprovedAds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('$baseUrl/api/ads/approved'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<List> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('$baseUrl/api/admin/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<List<dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$baseUrl/api/admin/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<bool> toggleBan(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.put(
      Uri.parse('$baseUrl/api/admin/users/$userId/ban'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return res.statusCode == 200;
  }

  static Future<bool> changeRole(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.put(
      Uri.parse('$baseUrl/api/admin/users/$userId/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': role}),
    );

    return res.statusCode == 200;
  }
}
