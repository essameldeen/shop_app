import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String token) async {
    var oldValue = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://fluter-project-default-rtdb.firebaseio.com/products/$id.json?auth=$token';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({'isFavourite': isFavourite}));
      if (response.statusCode >= 400) {
        isFavourite = oldValue;
        notifyListeners();
      }
    } catch (error) {
      isFavourite = oldValue;
      notifyListeners();
    }
  }
}
