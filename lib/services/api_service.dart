import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manual_model.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000/api/sign-languages";

  Future<List<Manual>> fetchManuals() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Manual.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load manuals');
    }
  }
}