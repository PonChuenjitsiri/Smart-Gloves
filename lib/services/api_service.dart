import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manual_model.dart';

class ApiService {
  final String baseUrl = "https://smb.pon-hub.com/api/sign-languages";

  Future<List<Manual>> fetchManuals() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      // Decode with UTF-8 to support Thai characters
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((data) => Manual.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load manuals');
    }
  }

  Future<Manual> fetchManualById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Manual.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load manual details');
    }
  }
}