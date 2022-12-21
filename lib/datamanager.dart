import 'dart:convert';

import 'datamodel.dart';
import 'package:http/http.dart' as http;

import 'envvariables.dart';

class DataManager {
  List<ReceipeStep>? _receipe;

  fetchReceipe() async {
    var url = apiUrl;

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var body = response.body;
      _receipe = [];
      var decodedData = jsonDecode(body) as List<dynamic>;
      for (var json in decodedData) {
        _receipe?.add(ReceipeStep.fromJson(json));
      }
    }
  }

  Future<List<ReceipeStep>> getReceipe() async {
    if (_receipe == null) {
      await fetchReceipe();
    }
    return _receipe!;
  }
}
