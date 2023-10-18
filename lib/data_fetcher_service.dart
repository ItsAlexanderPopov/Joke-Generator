import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DataService with ChangeNotifier {
  final String apiUrl;

  DataService(this.apiUrl);

  String? setup;
  String? delivery;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setup = data['setup'];
      delivery = data['delivery'];
      notifyListeners();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void refreshData() {
    fetchData();
  }
}
