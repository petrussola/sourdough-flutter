import 'dart:convert';

import 'datamodel.dart';
import 'package:http/http.dart' as http;

import 'envvariables.dart';

class DataManager {
  List<ReceipeType>? _receipes;

  fetchReceipes() async {
    var url = apiUrl;

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _receipes = [];

      var body = response.body;
      var decodedData = jsonDecode(body) as List<dynamic>;

      for (var json in decodedData) {
        _receipes?.add(ReceipeType.fromJson(json));
      }
    }
  }

  Future<List<ReceipeType>> getReceipes() async {
    if (_receipes == null) {
      await fetchReceipes();
    }
    return _receipes!;
  }
}
