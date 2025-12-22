import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Future<Map<String, dynamic>> predict(
      Map<String, dynamic> payload) async {
    final url = Uri.parse('$kApiBaseUrl/predict');

    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Server error ${resp.statusCode}: ${resp.body}');
    }
  }
}


